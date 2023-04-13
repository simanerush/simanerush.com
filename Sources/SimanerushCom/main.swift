import Foundation
import Publish
import Plot
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct SimanerushCom: Website {
  enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:
    case posts
  }
  
  struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
  }
  
  // Update these properties to configure your website:
  var url = URL(string: "https://www.simanerush.com/")!
  var name = "Sima's Swifty Blog"
  var description = "A collection of Swift and iOS Development articles by Sima Nerush"
  var language: Language { .english }
  var imagePath: Path? { nil }
  var favicon: Favicon? { .init() }
}

// MARK: - Publishing steps
try SimanerushCom().publish(using: [
  .installPlugin(.splash(withClassPrefix: "")),
  .addMarkdownFiles(),
  .copyResources(),
  .generateHTML(withTheme: .swifty),
  .generateRSSFeed(including: [.posts]),
  .generateSiteMap(),
  .deploy(using: .gitHub("simanerush/simanerush.com", useSSH: true)),
])
