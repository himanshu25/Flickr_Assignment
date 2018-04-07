//
//  Flickr.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto: NSObject {
    
    private var photoId: String!
    private var farm: Int!
    private var secret: String!
    private var server: String!
    var title: String!
    var url: URL!
     
     init(photoDictionary: NSDictionary) {
          let photoId = photoDictionary["id"] as? String ?? ""
          let farm = photoDictionary["farm"] as? Int ?? 0
          let secret = photoDictionary["secret"] as? String ?? ""
          let server = photoDictionary["server"] as? String ?? ""
          let title = photoDictionary["title"] as? String ?? ""
          self.photoId = photoId
          self.farm = farm
          self.secret = secret
          self.server = server
          self.title = title
          self.url = URL(string: "https://farm\(farm).static.flickr.com/\(server)/\(photoId)_\(secret).jpg")!
     }
}
