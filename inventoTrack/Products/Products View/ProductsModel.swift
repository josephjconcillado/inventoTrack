//
//  ProductModel.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-22.
//

import Foundation

enum DisplayMode: String {
    case grid = "grid"
    case list = "list"
}

enum SortOrder: String {
    case name = "Sort by Name"
    case price = "Sort by Price"
    case quantity = "Sort by Quantity"
    case dateCreated = "Sort by Date"
}

enum ViewMode {
    case view
    case select
}
