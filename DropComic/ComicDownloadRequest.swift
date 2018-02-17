//
//  ComicDownloadRequest.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit

typealias ComicDownloadRequestProgressCallback = (_ : Float) -> Void
typealias ComicDownloadRequestSuccessCallback = (_ : URL) -> Void

class ComicDownloadRequest: NSObject {
  var progressCallback : ComicDownloadRequestProgressCallback?
  var successCallback : ComicDownloadRequestSuccessCallback?
  
  @discardableResult func progress(callback: @escaping ComicDownloadRequestProgressCallback) -> Self {
    self.progressCallback = callback
    return self
  }
  
  @discardableResult func success(callback : @escaping ComicDownloadRequestSuccessCallback) -> Self {
    self.successCallback = callback
    return self
  }
}
