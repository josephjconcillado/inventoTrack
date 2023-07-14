//
//  Sort+CoreDataProperties.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-14.
//
//

import Foundation
import CoreData


extension Sort {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sort> {
        return NSFetchRequest<Sort>(entityName: "Sort")
    }

    @NSManaged public var sortOption: Int16

}

extension Sort : Identifiable {

}
