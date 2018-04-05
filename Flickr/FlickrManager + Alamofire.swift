//
//  FlickrManager + Alamofire.swift
//  Flickr
//
//  Created by Himanshu on 05/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension FlickrManager {
    func request(url: String, type: HTTPMethod, with completion: @escaping flickrCompletionBlock) {
        Alamofire.request(url, method: type).responseJSON { response in
            response.result.ifSuccess {
                DispatchQueue.main.async {
                        do {
                            let responseResult = response.result
                            let resultsDictionary = responseResult.value as? [String: AnyObject]
                            guard let _ = resultsDictionary, let photosContainer = resultsDictionary![self.photos] as? NSDictionary, let photosArray = photosContainer[self.photo] as? [NSDictionary] else { return }
                            let flickrPhotoArray: [FlickrPhoto] = photosArray.map { photoDictionary in
                                let flickrPhoto = FlickrPhoto(photoDictionary: photoDictionary)
                                return flickrPhoto
                            }
                            completion(nil, flickrPhotoArray)
                        } catch let error as NSError {
                            completion(error as NSError?, nil)
                        }
                }
            }
            response.result.ifFailure {
                DispatchQueue.main.async {
                    let code = response.response?.statusCode ?? 0
                    completion(nil, [])
                }
            }
        }
    }
}
