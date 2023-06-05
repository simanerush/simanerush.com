//
//  Theme+Swifty.swift
//  SimanerushCom
//
//  Created by Sima Nerush on 4/12/23.
//

import Plot
import Publish

public extension Theme {
  static var swifty: Self {
    Theme(
      htmlFactory: SwiftyHTMLFactory(),
      resourcePaths: ["Resources/SwiftyTheme/styles.css"]
    )
  }
}

private struct SwiftyHTMLFactory<Site: Website>: HTMLFactory {
  func makeIndexHTML(for index: Index,
                     context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: index, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H2(index.title)
          ItemList(
            items: context.allItems(
              sortedBy: \.date,
              order: .descending
            ),
            site: context.site
          )
        }
        SiteFooter()
      }
    )
  }
  
  func makeSectionHTML(for section: Section<Site>,
                       context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: section, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: section.id)
        Wrapper {
          H1(section.title)
          if section.title == "About" {
            Article {
              Div(section.items[0].content.body).class("content")
              if section.title != "About" {
                Span("Tagged with: ")
              }
              ItemTagList(item: section.items[0], site: context.site)
            }
          } else {
            ItemList(items: section.items, site: context.site)
          }
        }
        SiteFooter()
      }
    )
  }
  
  func makeItemHTML(for item: Item<Site>,
                    context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: item, on: context.site),
      .body(
        .class("item-page"),
        .components {
          SiteHeader(context: context, selectedSelectionID: item.sectionID)
          Wrapper {
            Article {
              Div(item.content.body).class("content")
              Span("Tagged with: ")
              ItemTagList(item: item, site: context.site)
            }
          }
          SiteFooter()
        }
      )
    )
  }
  
  func makePageHTML(for page: Page,
                    context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper(page.body)
        SiteFooter()
      }
    )
  }
  
  func makeTagListHTML(for page: TagListPage,
                       context: PublishingContext<Site>) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H1("Browse all tags")
          List(page.tags.sorted()) { tag in
            ListItem {
              Link(tag.string,
                   url: context.site.path(for: tag).absoluteString
              )
            }
            .class("tag")
          }
          .class("all-tags")
        }
        SiteFooter()
      }
    )
  }
  
  func makeTagDetailsHTML(for page: TagDetailsPage,
                          context: PublishingContext<Site>) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H1 {
            Text("Tagged with ")
            Span(page.tag.string).class("tag")
          }
          
          Link("Browse all tags",
               url: context.site.tagListPath.absoluteString
          )
          .class("browse-all")
          
          ItemList(
            items: context.items(
              taggedWith: page.tag,
              sortedBy: \.date,
              order: .descending
            ),
            site: context.site
          )
        }
        SiteFooter()
      }
    )
  }
}

private struct Wrapper: ComponentContainer {
  @ComponentBuilder var content: ContentProvider
  
  var body: Component {
    Div(content: content).class("wrapper")
  }
}

private struct SiteHeader<Site: Website>: Component {
  var context: PublishingContext<Site>
  var selectedSelectionID: Site.SectionID?
  
  var body: Component {
    Header {
      Wrapper {
        headerLink
        
        if Site.SectionID.allCases.count > 1 {
          navigation
        }
      }
    }
  }
  
  private var headerLink: Component {
    Div {
      ComponentGroup(members:
                      [
                        Link(context.site.name, url: "/")
                          .class("site-name"),
                        Div {
                          ComponentGroup(members: [
                            Link(url: "https://github.com") {
                              Image(url: "/images/github.svg", description: "github")
                                .class("link-image")
                            }.class("special-link"),
                            Link(url: "https://linkedin.com") {
                              Image(url: "/images/linkedin.svg", description: "linkedin")
                                .class("link-image")
                            }.class("special-link"),
                          ])
                        }.class("special-links")
                      ]
      )
    }
    .class("all-links")
  }
  
  private var navigation: Component {
    Navigation {
      List(Site.SectionID.allCases) { sectionID in
        let section = context.sections[sectionID]
        
        return Link(section.title,
                    url: section.path.absoluteString
        )
        .class(sectionID == selectedSelectionID ? "selected" : "")
      }
    }
  }
}

private struct ItemList<Site: Website>: Component {
  var items: [Item<Site>]
  var site: Site
  
  var body: Component {
    List(items.filter { $0.title != "about-me"}) { item in
        Article {
          H1(Link(item.title, url: item.path.absoluteString))
          ItemTagList(item: item, site: site)
          Paragraph(item.description)
        }
    }
    .class("item-list")
  }
}

private struct ItemTagList<Site: Website>: Component {
  var item: Item<Site>
  var site: Site
  
  var body: Component {
    List(item.tags) { tag in
      Link(tag.string, url: site.path(for: tag).absoluteString)
    }
    .class("tag-list")
  }
}

private struct SiteFooter: Component {
  var body: Component {
    Footer {
      Paragraph {
        Text("© Sima Nerush 2023 💛 Generated using ")
        Link("Publish", url: "https://github.com/johnsundell/publish")
      }
      Paragraph {
        Link("RSS feed", url: "/feed.rss")
      }
    }
  }
}
