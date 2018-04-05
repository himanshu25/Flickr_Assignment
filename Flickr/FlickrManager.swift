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
    let photoId = "id"
    let farm = "farm"
    let secret = "secret"
    let server = "server"
    let title =  "title"
    
    static var imageURLDict:[String: UIImage] = [:]
    var currentSearchedText = ""
    static let sharedInstance = FlickrManager()
    typealias flickrCompletionBlock = (NSError?, [FlickrPhoto]?) -> Void
    let urlConfig = URLSessionConfiguration.default
    
    public func getPhotosWithText(text: String, with completion: @escaping flickrCompletionBlock) -> Void {
        let apiURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f2ddfcba0e5f88c2568d96dcccd09602&format=json&nojsoncallback=1&safe_search=1&text=\(text)"
        guard let url = URL(string: apiURL) else {
            completion(nil, nil)
            return }
        let session = URLSession(configuration: urlConfig)
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(error as NSError?, nil)
                return
            }
            if let data = data {
                do {
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                    guard let _ = resultsDictionary else { return }
                    guard let photosContainer = resultsDictionary![self.photos] as? NSDictionary else { return }
                    guard let photosArray = photosContainer[self.photo] as? [NSDictionary] else { return }
                    let flickrPhotoArray: [FlickrPhoto] = photosArray.map { photoDictionary in
                        let photoId = photoDictionary[self.photoId] as? String ?? ""
                        let farm = photoDictionary[self.farm] as? Int ?? 0
                        let secret = photoDictionary[self.secret] as? String ?? ""
                        let server = photoDictionary[self.server] as? String ?? ""
                        let title = photoDictionary[self.title] as? String ?? ""
                        let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                        return flickrPhoto
                    }
                    completion(nil, flickrPhotoArray)
                } catch let error as NSError {
                    completion(error as NSError?, nil)
                }
            }
        }
        dataTask.resume()
    }
}
