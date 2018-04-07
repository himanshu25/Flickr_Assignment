//
//  FlickrSearchDetailViewController.swift
//  Flickr
//
//  Created by Himanshu on 07/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

class FlickrSearchDetailViewController: UIViewController {
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var flickrPhoto: FlickrPhoto!
    private var imageTitle = ""
    private var image: UIImage!
    static func viewController(flickrPhoto: FlickrPhoto) -> FlickrSearchDetailViewController {
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let searchDetailVC = mainView.instantiateViewController(withIdentifier: "searchDetailVC") as! FlickrSearchDetailViewController
        searchDetailVC.flickrPhoto = flickrPhoto
        return searchDetailVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTitleLabel.text = flickrPhoto.title
        imageView.image =  FlickrManager.imageURLDict[flickrPhoto.url.absoluteString]
    }
    
}
