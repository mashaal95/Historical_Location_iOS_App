//
//  HistPlace+CoreDataProperties.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 6/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//
//

import Foundation
import CoreData


extension HistPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistPlace> {
        return NSFetchRequest<HistPlace>(entityName: "HistPlace")
    }

    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: String?

}
