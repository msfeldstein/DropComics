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

class ComicReaderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pageCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath)
    let imageView = cell.viewWithTag(1) as! UIImageView
    do {
      guard let data = try self.rarchive?.extractData(self.rarchive!.listFileInfo()[indexPath.row], progress: nil) else {
        fatalError()
      }
      let image = UIImage(data: data)
      imageView.image = image
    } catch {
    
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  @IBOutlet var progressBar : UIProgressView!
  @IBOutlet var collectionView : UICollectionView!
  var pages = [String]()
  var pageCount = 0
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
    if pages.count > 0 {
      self.pageCount = pages.count
      self.collectionView.isHidden = false
      self.collectionView.reloadData()
    }
  }
  
  override func viewWillLayoutSubviews() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
