//
//  ImageDownloader.swift
//  Flickr
//
//  Created by Himanshu on 07/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
typealias ImageDownloaderCompletionBlock = (_ image: UIImage) -> Void

enum ImageDownloaderState {
    case Downloading
    case Done
}
class DownloadStateInformation {
    var state: ImageDownloaderState
    var image: UIImage?
    var completion: ImageDownloaderCompletionBlock?
    init(state: ImageDownloaderState, completion: ImageDownloaderCompletionBlock? ) {
        self.state = state
        self.completion = completion
    }
}

class ImageDownloader: NSObject {
    private var dict: [String: DownloadStateInformation] = [:]
    static let sharedInstance = ImageDownloader()
    func downloadedFrom(url: URL, completion: ImageDownloaderCompletionBlock?) {
        if let stateInfo = dict[url.absoluteString], stateInfo.state == .Downloading {
            stateInfo.completion = completion
        }
        else {
            let stateInformation = DownloadStateInformation(state: .Downloading, completion: completion)
            dict[url.absoluteString] = stateInformation
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                stateInformation.image = image
                completion?(image)
                stateInformation.completion = nil
                stateInformation.state = .Done
                }.resume()
        }
       
}
}
