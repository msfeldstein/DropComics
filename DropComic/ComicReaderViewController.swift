//
//  ComicReaderViewController.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox
import UnrarKit

class ComicReaderViewController: UIViewController {
  @IBOutlet var progressBar : UIProgressView!
  @IBOutlet var pageImage : UIImageView!
  var pages = [String]()
  var rarchive : URKArchive?
  var comicMetadata : Files.FileMetadata! {
    didSet {
      ComicDownloader.sharedInstance.startDownload(path: comicMetadata.pathLower!)
      .success { url in
        do {
          self.rarchive = try URKArchive(url: url)
          self.pages = try self.rarchive!.listFilenames()
          self.reload()
        } catch {
          fatalError()
        }
      }
      .progress { progressData in
        self.progressBar.progress = progressData
      }
    }
  }
  
  func reload() {
    do {
      if pages.count > 0 {
        guard let data = try self.rarchive?.extractData(self.rarchive!.listFileInfo()[0], progress: { (f) in
          print("F", f)
        }) else {
          fatalError()
        }
        let image = UIImage(data: data)
        self.pageImage.image = image
      }
    } catch {
      fatalError()
    }
  }
}
