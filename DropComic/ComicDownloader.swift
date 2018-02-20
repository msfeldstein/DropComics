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

enum ComicDownloadState {
  case Uncached
  case Cached
  case Downloading
}

class ComicDownloadInfo {
  var state : ComicDownloadState = .Uncached
  var progress : Float = 0
}

class ComicDownloader {
  static let ProgressUpdateNotification = Notification.Name(rawValue: "downloadProgressUpdate")
  static let sharedInstance = ComicDownloader()
  
  var currentDownloadPath = ""
  var currentBatch = [Files.Metadata]()
  var changedCallback : (() -> Void)?
  var currentProgress : Float = 0
  
  func getDownloadState(path : String) -> ComicDownloadInfo {
    let info = ComicDownloadInfo()
    if isCached(path: path) {
      info.state = .Cached
    } else if currentDownloadPath == path {
      info.state = .Downloading
      info.progress = currentProgress
    } else {
      info.state = .Uncached
    }
    return info
  }
  
  func isCached(path : String) -> Bool {
    guard let cacheKey = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      fatalError("Couldn't create cache key for path \(path)")
    }
    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let destURL = directoryURL.appendingPathComponent(cacheKey)
    return FileManager.default.fileExists(atPath: destURL.path)
  }
  
  func downloadBatch(comics : [Files.Metadata], changed : @escaping (() -> Void)) {
    currentBatch = comics
    changedCallback = changed
    downloadNext()
  }
  
  func downloadNext() {
    if currentBatch.count == 0 {
      currentDownloadPath = ""
      return
    }
    let nextComic = currentBatch.removeFirst()
    currentDownloadPath = nextComic.pathLower!
    currentProgress = 0
    ComicDownloader.sharedInstance.startDownload(path: nextComic.pathLower!)
    .progress { progress in
      self.currentProgress = progress
      let notification = Notification(name: ComicDownloader.ProgressUpdateNotification)
      NotificationCenter.default.post(notification)
    }
    .success { url in
      self.changedCallback?()
      self.downloadNext()
    }
    self.changedCallback?()
  }
  
  func startDownload(path : String) -> ComicDownloadRequest {
    guard let client = DropboxClientsManager.authorizedClient else {
      fatalError("Trying to download without an authorized Dropbox client")
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
