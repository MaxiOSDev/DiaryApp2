//
//  Entry+CoreDataProperties.swift
//  
//
//  Created by Max Ramirez on 3/7/18.
//
//

import Foundation
import CoreData
import UIKit

extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.sortDescriptors = [NSSortDescriptor(key: "dateHelper", ascending: false)]
        return request
    }

    @NSManaged public var date: NSDate
    @NSManaged public var dateHelper: NSDate
    @NSManaged public var location: String?
    @NSManaged public var photo: [NSData]
    @NSManaged public var status: String?
    @NSManaged public var text: String

}

extension Entry {
    var image: [UIImage] {
        print("Photo array count \(photo.count)")
        var tempArray = [UIImage]()
        for data in self.photo {
            let image = UIImage(data: data as Data)!
            tempArray.append(image)
        }
        return tempArray
    }
}
