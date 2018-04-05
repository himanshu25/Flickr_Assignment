//
//  FlickrSearchDataSource.swift
//  Flickr
//
//  Created by Himanshu on 05/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

protocol FlickrSearchPagingDelegate: class {
    func reloadData(pageNumber: Int)
    func insertPaths(path: [IndexPath])
}

class FlickrSearchDataSourceAndDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var photosArray = [FlickrPhoto]()
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    var cellsPerRow = 2
    var pageNumber = 1
    weak var delegate: FlickrSearchPagingDelegate?
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrSearchCell", for: indexPath) as! SearchCell
        cell.setupWithPhoto(flickr: photosArray[indexPath.row])
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photosArray.count - 1 {
            moreData()
        }
    }
    
    // Paging
    func moreData() {
        pageNumber += 1
        delegate?.reloadData(pageNumber: pageNumber)
    }
    
    func insertMore() {
        var paths = [IndexPath]()
        for _ in 0..<10 {
            paths.append(IndexPath(row: photosArray.count - 1, section: 0))
        }
        delegate?.insertPaths(path: paths)
    }
    
    func setCellsPerRow() {
        if UIDevice.current.orientation.isLandscape  {
            cellsPerRow = 3
        }
        else {
            cellsPerRow = 2
        }
    }
}
