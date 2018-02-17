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
  var file : Files.Metadata? {
    didSet {
      self.name.text = file?.name
    }
  }
}
