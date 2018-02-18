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
  
  func startDownload(path : String) -> ComicDownloadRequest {
    // Download to URL
    guard let client = DropboxClientsManager.authorizedClient else {
      fatalError()
    }
    
    
    
    let request = ComicDownloadRequest()
    
    guard let cacheKey = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      fatalError("Couldn't create cache key for path \(path)")
    }
    
    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let destURL = directoryURL.appendingPathComponent(cacheKey)
    if FileManager.default.fileExists(atPath: destURL.path) {
      DispatchQueue.main.async {
        request.progressCallback?(1)
        request.successCallback?(destURL)
      }
      return request
    }

    let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
        return destURL
    }
    client.files.download(path: path, overwrite: true, destination: destination)
    .progress { (progress) in
      request.progressCallback?(Float(progress.fractionCompleted))
    }
    .response { response, error in
      if let response = response {
        request.successCallback?(response.1)
      }
    }
    return request
  }
}
