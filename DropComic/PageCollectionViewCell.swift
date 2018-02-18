//
//  PageCollectionViewCell.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit

class PageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var scroller : UIScrollView!
  
    var image : UIImage? {
      didSet {
        imageView.image = image
        scroller.delegate = self
        scroller.maximumZoomScale = 5.0
        scroller.contentSize = self.contentView.bounds.size
      }
    }
  
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//      return self.imageView
//    }
}
