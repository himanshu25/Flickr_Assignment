//
//  SearchCell.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

class SearchCell: UICollectionViewCell {
    @IBOutlet weak var flickrImageView: UIImageView!
    
    func setupWithPhoto(flickr: FlickrPhoto) {
        // Remove comment if you want to use SDWebImage
        // flickrImageView.sd_setImage(with: flickr.url!)
        flickrImageView.image = UIImage(named: "placeholder")
        flickrImageView.downloadedFrom(url: flickr.url, contentMode: .scaleAspectFit)
    }
    
}

