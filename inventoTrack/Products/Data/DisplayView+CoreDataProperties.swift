//
//  DisplayView+CoreDataProperties.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-14.
//
//

import Foundation
import CoreData


extension DisplayView {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DisplayView> {
        return NSFetchRequest<DisplayView>(entityName: "DisplayView")
    }

    @NSManaged public var viewOption: Bool

}

extension DisplayView : Identifiable {

}
