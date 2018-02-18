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
      self.title = comicMetadata.name
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
    goToPage(page: currentPage() - 1)
  }
  
  @IBAction func nextPage() {
    goToPage(page: currentPage() + 1)
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
      if let data = ComicDataCache.getComicData(path: self.comicMetadata.pathLower!) {
        goToPage(page: data.lastPageRead, animated: false)
      }
    }
  }
  
  func goToPage(page : Int, animated : Bool = true) {
    if page >= pageCount || page < 0 { return }
    let path = IndexPath(row: page, section: 0)
    self.collectionView.scrollToItem(at: path, at: .centeredHorizontally, animated: animated)
  }
  
  func currentPage() -> Int {
    return self.collectionView.indexPathsForVisibleItems.first?.row ?? 0
  }
  
  override func viewWillLayoutSubviews() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.hidesBarsOnTap = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    let data = ComicDataCache.getComicData(path: comicMetadata.pathLower!) ?? ComicData()
    data.lastPageRead = currentPage()
    data.pageCount = self.pageCount
    ComicDataCache.setComicData(path: comicMetadata.pathLower!, comic: data)
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
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
}
