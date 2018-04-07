//
//  DataManager.swift
//  Flickr
//
//  Created by Himanshu on 07/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject {
    static let sharedInstance = DataManager()
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func request() -> NSFetchRequest<NSFetchRequestResult> {
        NSEntityDescription.entity(forEntityName: "FlickrSearch", in: getContext())
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrSearch")
        request.returnsObjectsAsFaults = false
        return request
    }
}
