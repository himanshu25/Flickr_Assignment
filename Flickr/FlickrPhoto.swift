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
    
    var photoId: String!
    var farm: Int!
    var secret: String!
    var server: String!
    var title: String!
    var url: URL!
     
     init(photoId: String, farm: Int, secret: String, server: String, title: String) {
          self.photoId = photoId
          self.farm = farm
          self.secret = secret
          self.server = server
          self.title = title
          self.url = URL(string: "https://farm\(farm).static.flickr.com/\(server)/\(photoId)_\(secret).jpg")!
     }
}
