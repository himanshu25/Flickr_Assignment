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

    private var imageTitle = ""
    private var image: UIImage!
    static func viewController(title: String, image: UIImage) -> FlickrSearchDetailViewController {
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let searchDetailVC = mainView.instantiateViewController(withIdentifier: "searchDetailVC") as! FlickrSearchDetailViewController
        searchDetailVC.imageTitle = title
        searchDetailVC.image = image
        return searchDetailVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTitleLabel.text = imageTitle
        imageView.image = image
    }
    
}
