//
//  FlickrSearch+CoreDataProperties.swift
//  
//
//  Created by Himanshu on 05/04/18.
//
//

import Foundation
import CoreData


extension FlickrSearch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickrSearch> {
        return NSFetchRequest<FlickrSearch>(entityName: "FlickrSearch")
    }

    @NSManaged public var text: String?
    @NSManaged public var time: Int32

}
