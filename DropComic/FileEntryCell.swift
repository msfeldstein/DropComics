//
//  FileEntry.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileEntryCell: UITableViewCell {
  @IBOutlet var name : UILabel!
  @IBOutlet var pageCounts : UILabel!
  @IBOutlet var downloadIcon : UIImageView!
  @IBOutlet var downloadProgress : UIProgressView!
  var file : Files.Metadata? {
    didSet {
      guard let file = file else { return }
      self.name.text = file.name
      if let data = ComicDataCache.getComicData(path: file.pathLower!) {
        pageCounts.isHidden = false
        pageCounts.text = "\(data.lastPageRead) / \(data.pageCount)"
      } else {
        pageCounts.isHidden = true
      }
      let downloadInfo = ComicDownloader.sharedInstance.getDownloadState(path: file.pathLower!)
      if downloadInfo.state == .Downloading {
        NotificationCenter.default.addObserver(self, selector: #selector(FileEntryCell.updateProgress), name: ComicDownloader.ProgressUpdateNotification, object: nil)
      } else {
        NotificationCenter.default.removeObserver(self, name: ComicDownloader.ProgressUpdateNotification, object: nil)
      }
      updateProgress()
    }
  }
  
  @objc func updateProgress() {
    guard let file = file else { return }
    let downloadInfo = ComicDownloader.sharedInstance.getDownloadState(path: file.pathLower!)
      if downloadInfo.state == .Cached {
        self.downloadIcon.isHidden = false
      } else {
        self.downloadIcon.isHidden = true
      }
      if downloadInfo.state == .Downloading {
        downloadProgress.isHidden = false
        downloadProgress.progress = downloadInfo.progress
      } else {
        downloadProgress.isHidden = true
      }
  }
}
