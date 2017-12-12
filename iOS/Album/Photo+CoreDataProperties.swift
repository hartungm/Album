//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Michael Hartung on 3/26/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var name: String?
    @NSManaged public var data: NSData?
    @NSManaged public var album: Album?

}
