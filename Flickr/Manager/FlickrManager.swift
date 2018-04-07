//
//  FlickrManager.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

class FlickrManager {
    
    // Constants
    let photos = "photos"
    let photo = "photo"
    let pageNumber = 1
    
    static var imageURLDict:[String: UIImage] = [:]
    static var sharedInstance = FlickrManager()
    typealias flickrCompletionBlock = (NSError?, [FlickrPhoto]?) -> Void
    let urlConfig = URLSessionConfiguration.default
    
    public func getPhotosWithText(text: String, pageNumber: Int, with completion: @escaping flickrCompletionBlock) -> Void {
        if let searchText = text.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed) {
            let apiURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f2ddfcba0e5f88c2568d96dcccd09602&per_page=10&format=json&nojsoncallback=1&safe_search=1&text=\(searchText)&page=\(pageNumber)"
            request(url: apiURL, type: .get) { (error, photoArray) in
                completion(nil, photoArray ?? [])
            }
        }
    }
}
