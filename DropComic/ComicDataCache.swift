//
//  ComicDataCache.swift
//  DropComix
//
//  Created by Mike Feldstein on 2/18/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit

class ComicData : NSObject, NSCoding {
  var pageCount = 0
  var lastPageRead = 0
  
  override init() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    pageCount = aDecoder.decodeInteger(forKey: "pageCount")
    lastPageRead = aDecoder.decodeInteger(forKey: "lastPageRead")
  }
  
  func encode(with aCoder: NSCoder) {
      aCoder.encode(pageCount, forKey: "pageCount")
      aCoder.encode(lastPageRead, forKey: "lastPageRead")
  }
  
  
}

class ComicDataCache: NSObject {
  static var data : Dictionary<String, ComicData> = {
    if let initData = UserDefaults.standard.object(forKey: "comicData") as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: initData) as! [String : ComicData]
    }
    return Dictionary<String, ComicData>()
  }()
  
  static func getComicData(path : String) -> ComicData? {
    return data[path]
  }
  
  static func setComicData(path : String, comic : ComicData) {
    data[path] = comic
    let encoded = NSKeyedArchiver.archivedData(withRootObject: data)
    UserDefaults.standard.set(encoded, forKey: "comicData")
  }
}
