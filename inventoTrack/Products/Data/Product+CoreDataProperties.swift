//
//  Product+CoreDataProperties.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-14.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var pBarcode: String?
    @NSManaged public var pDateCreated: Date?
    @NSManaged public var pDescription: String?
    @NSManaged public var pImage: Data?
    @NSManaged public var pName: String?
    @NSManaged public var pPrice: Double
    @NSManaged public var pQty: Int32

}

extension Product : Identifiable {

}
