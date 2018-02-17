//
//  ComicDownloader.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox
import Cache


class ComicDownloader {
  static let sharedInstance = ComicDownloader()
  
  let storage : Storage
  private init() {
    let diskConfig = DiskConfig(name: "Comic Bok")
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    self.storage = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
  }
  
  func startDownload(path : String) -> ComicDownloadRequest {
    // Download to URL
    guard let client = DropboxClientsManager.authorizedClient else {
      fatalError()
    }
    
    
    
    let request = ComicDownloadRequest()
    
    guard let cacheKey = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      fatalError("Couldn't create cache key for path \(path)")
    }
    
    do {
      let url = try self.storage.object(ofType: String.self, forKey: cacheKey)
      DispatchQueue.main.async {
        request.progressCallback?(1)
        request.successCallback?(URL(fileURLWithPath: url))
      }
      return request
    } catch {
      // need to fetch
    }
    
    let fileManager = FileManager.default
    let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let destURL = directoryURL.appendingPathComponent(cacheKey)
    let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURL
    }
    client.files.download(path: path, overwrite: true, destination: destination)
    .progress { (progress) in
      request.progressCallback?(Float(progress.fractionCompleted))
    }
    .response { response, error in
      if let response = response {
        try? self.storage.setObject(response.1.path, forKey: cacheKey)
        request.successCallback?(response.1)
      }
    }
    return request
  }
}
