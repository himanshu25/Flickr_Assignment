//
//  UIImageView+download.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

// Using it for caching, we can invalidate it when we want or if don't want to use it then go for SDWebImage

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill) {
        contentMode = mode
        if let image = FlickrManager.imageURLDict[url.absoluteString] {
            self.image = image
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else { return }
                FlickrManager.imageURLDict[url.absoluteString] = image
                DispatchQueue.main.async() {
                    self.image = image
                }
                }.resume()
        }
    }
}
