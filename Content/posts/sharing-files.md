---
date: 2023-04-25 20:00
description: Learn how to share files with ShareLink
tags: SwiftUI, Transferable
---
#  Sharing files in SwiftUI



A new CoreTransferable framework makes it easy to share data in SwiftUI with `ShareLink`. 

In this article, we will be talking about sharing files using `ShareLink`, while preserving their name and extension. Let's look at how to share a PDF file.

## Before we start

First, we need an actual file as a property of our view, and data that will populate our PDF.

Don't forget to import `PDFKit`!

```
@State private var pdfDocument: PDFDocument = PDFDocument()
@State private var data: Data = Data()
@State private var previewImage: Image = Image("")
@State private var filename: String
```
Here, we are defining properies of our view that will be required for populating the `ShareLink`. But, there's one more thing we need to implement before we can populate them!

## Implementing a preview image for our PDF

Since a `ShareLink` can optionally take a preview image that will be shown on a share sheet, we need to write an extension for the `PDFDocument` type:

```
extension PDFDocument {
  public var imageRepresenation: UIImage? {
    guard let pdfPage = self.page(at: 0) else { return nil }
    let pageBounds = pdfPage.bounds(for: .cropBox)

    let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
    let image = renderer.image { ctx in
      UIColor.white.set()
      ctx.fill(pageBounds)

      ctx.cgContext.translateBy(x: 0.0, y: pageBounds.size.height)
      ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(ctx.cgContext)
      pdfPage.draw(with: .cropBox, to: ctx.cgContext)
      UIGraphicsPopContext()
    }
    return image
  }
}
```

This will create and render an image presentation for any instance of a `PDFDocument`.

Now, we have an image that we can pass to the `ShareLink`!


## Creating the PDF

In our view's `.onAppear` modifier, we can create our file and its image like so:

```
.onAppear {
  guard let pdf = PDFDocument(data: data),
  let image = pdf.imageRepresenation else {
    fatalError("something went wrong...")
  }

  // Set the name of the file!
  pdf.documentAttributes![PDFDocumentAttribute.titleAttribute] = filename
  self.pdfDocument = pdf
  self.previewImage = Image(uiImage: image)
}
```

Here, we are populating our view's `pdfDocument` and `previewImage` properties to hold the PDF document and its preview image.

The most important part is to set the title attribute to our PDF's name. This is a **very** important step since this will make the saved file to have the right name.

## Getting a PDF's title

As we have seen, it is not really convenient to access a title of a given PDF, because it is stored in its metadata and is of type `Optional<Dictionary<AnyHashable, Any>>`. 

Because of that, let's write another function that will extend the `PDFDocument` to get its title.

```
extension PDFDocument {
  public var title: String? {
  guard let attributes = self.documentAttributes,
        let titleAttribute = attributes[PDFDocumentAttribute.titleAttribute]
  else { return nil }

  return titleAttribute as? String
  }
}
``` 
This checks if a title attribute exists and converts it to a `String`. 

## Conforming to `Transferable`

Finally, to pass our PDF document to the `ShareLink`, we need a `PDFDocument` to conform to the `Transferable` protocol.

```
extension PDFDocument: Transferable {
public static var transferRepresentation: some TransferRepresentation {
  FileRepresentation(exportedContentType: .pdf) { pdf in
    guard let data = pdf.dataRepresentation() else {
    fatalError("Could not create a pdf file")
    }

    var fileURL = FileManager.default
      .temporaryDirectory

    if let title = pdf.title {
      fileURL = fileURL
        .appendingPathComponent(title)
    }

    try data.write(to: fileURL)
    return SentTransferredFile(fileURL)
    }
  }
}

```

Since we want to specifically share as a file, we only need to implement `FileRepresentation`.

Here, we specify that we need a PDF content type. Then, we create a new file URL and optionally provide a title if it exists. (Here's why we wrote that title extension earlier!) Finally, we write our file to that URL and return it as a `SentTransferredFile`. This is a return type for a `FileRepresentation`.

## Creating the ShareLink

Finally, we can create a `ShareLink` in our view and place it in the Toolbar.

```
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
      ShareLink(item: pdfDocument,
        preview: SharePreview(
          filename,
          image: previewImage
        )
      )
  }
}
```

This will successfully present a share sheet with a correct name for the PDF and a preview image! Note that once you save it, the name of the file will be preserved, too!

Thank you for reading, and I hope you enjoyed this article! 💛
