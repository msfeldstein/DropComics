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

class ComicReaderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
  @IBOutlet var progressBar : UIProgressView!
  @IBOutlet var collectionView : UICollectionView!
  @IBOutlet var errorText : UILabel!

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
          self.showError("Not a valid comic file")
        }
      }
      .progress { progressData in
        self.progressBar.progress = progressData
      }
    }
  }
  
  @IBAction func previousPage() {
    guard var currentPage = self.collectionView.indexPathsForVisibleItems.first else {
      print("No current page i guess")
      return
    }
    if currentPage.row == 0 { return }
    currentPage.row -= 1
    self.collectionView.scrollToItem(at: currentPage, at: .centeredHorizontally, animated: true)
  }
  
  @IBAction func nextPage() {
    guard var currentPage = self.collectionView.indexPathsForVisibleItems.first else {
      print("No current page i guess")
      return
    }
    currentPage.row += 1
    if currentPage.row >= pageCount { return }
    self.collectionView.scrollToItem(at: currentPage, at: .centeredHorizontally, animated: true)
  }
  
  func showError(_ err: String) {
    self.errorText.text = err
    self.errorText.isHidden = false
    self.errorText.layoutIfNeeded()
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
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.hidesBarsOnTap = true
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pageCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PageCollectionViewCell
    do {
      guard let data = try self.rarchive?.extractData(self.rarchive!.listFileInfo()[indexPath.row], progress: nil) else {
        fatalError()
      }
      let image = UIImage(data: data)
      cell.image = image
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
}
