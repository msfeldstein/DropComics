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
    }
  }
}
