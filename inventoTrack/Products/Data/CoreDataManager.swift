//
//  CoreDataManager.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-14.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "MyProducts")
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores {
            (descrition, error) in guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataManager {
    func createProduct(barcode: String, name: String, description: String, quantity: String, price: String, image: Data) {
        let product = Product(context: viewContext)
        
        product.pDateCreated = Date()
        product.pBarcode = barcode
        product.pName = name
        product.pDescription = description
        product.pQty = Int32(Int(quantity)!)
        product.pPrice = Double(price)!
        product.pImage = image
        save()
    }
    func initializeSortOption() {
        let sort = Sort(context: viewContext)
        sort.sortOption = 1
        save()
    }
    func initializeViewOption() {
        let view = DisplayView(context: viewContext)
        view.viewOption = false
        save()
    }
    func fetchViewOption() -> [DisplayView] {
        let request: NSFetchRequest<DisplayView> = DisplayView.fetchRequest()
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func fetchSortOption() -> [Sort] {
        let request: NSFetchRequest<Sort> = Sort.fetchRequest()
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func updateSortOption(sortOption: Int16) {
        let sort = Sort(context: viewContext)
        sort.sortOption = sortOption
        save()
    }
    
    func fetchProducts(sortOption: String) -> [Product] {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: sortOption, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func fetchData() -> [NSManagedObject]? {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pDateCreated", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return (try? viewContext.fetch(request)) ?? []
    }
    
    
    func deleteProduct(_ product: Product) {
        viewContext.delete(product)
        //        save()
    }
    func deleteAllProduct() {
        // Fetch all entity descriptions from the Core Data model
        let entityDescriptions = persistentContainer.managedObjectModel.entities
        
        // Iterate over each entity description and perform a batch delete request
        for entityDescription in entityDescriptions {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityDescription.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(deleteRequest)
                try viewContext.save()
            } catch let error {
                print("Failed to delete data for entity \(entityDescription.name!): \(error)")
            }
        }    }
    
    func convertToJSON(data: [NSManagedObject]) -> Data? {
        var json: Data?
        
        do {
            let jsonArray = try data.map { try $0.jsonObject() }
            json = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
        } catch let error {
            print("Failed to convert to JSON: \(error)")
        }
        
        return json
    }
    
    func convertJSONToCoreData(jsonData: Data) -> Bool {
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
                print("Invalid JSON format")
                return false
            }
            
            for json in jsonArray {
                // Create a new Core Data entity object
                let entity = NSEntityDescription.entity(forEntityName: "Product", in: viewContext)!
                let object = NSManagedObject(entity: entity, insertInto: viewContext)
                
                // Map the JSON values to the Core Data object
                for (key, value) in json {
                    if key == "pImage" {
                        let dataValue = value as? String
                        let data = convertBase64ToData(base64String: dataValue!)
                        object.setValue(data, forKey: key)
                        
                    } else if key == "pDateCreated" {
                        if let dateValue = value as? String, let date = convertStringToDate(dateString: dateValue) {
                            // Handle Date attribute
                            object.setValue(date, forKey: key)
                        }
                    }
                    else if key == "pQty" {
                        //                        if value is Int {
                        //                            if let intValue = value as? Int, let num = convertIntToInt32(num: intValue) {
                        //                                // Handle Date attribute
                        //                                object.setValue(num, forKey: key)
                        //                            }
                        //                        }  else
                        if value is String {
                            if let intValue = value as? String, let num = convertStringToInt(num: intValue) {
                                object.setValue(num, forKey: key)
                            }
                        } else {
                            object.setValue(value, forKey: key)
                        }
                    }
                    else if key == "pPrice" {
                        //                        if value is Double {
                        //                            if let doubleValue = value as? Double, let double = convertDoubleToDouble(double: doubleValue) {
                        //                                object.setValue(double, forKey: key)
                        //                            }
                        //                        } else
                        if value is String {
                            if let intValue = value as? String, let num = convertStringToDouble(num: intValue) {
                                object.setValue(num, forKey: key)
                            }
                        } else {
                            object.setValue(value, forKey: key)
                        }
                    }
                    else {
                        object.setValue(value, forKey: key)
                    }
                    
                }
            }
            
            // Save the changes to Core Data
            try viewContext.save()
            print("Core Data restored successfully")
            return true
        } catch let error {
            print("Failed to convert JSON to Core Data: \(error)")
            return false
        }
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: dateString)
    }
    
    func convertBase64ToData(base64String: String) -> Data? {
        return Data(base64Encoded: base64String)
    }
    
    func convertIntToInt32(num: Int) -> Int32? {
        return Int32(num)
        
    }
    func convertStringToInt(num: String) -> Int? {
        return Int(num)
    }
    
    func convertStringToDouble(num: String) -> Double? {
        return Double(num)
    }
    
    func convertDoubleToDouble(double: Double) -> Double? {
        return Double(double)
    }
    
}

extension NSManagedObject {
    func jsonObject() throws -> [String: Any] {
        var json: [String: Any] = [:]
        
        for attribute in entity.attributesByName {
            let attributeName = attribute.key
            if let attributeValue = self.value(forKey: attributeName) {
                if let date = attributeValue as? Date {
                    // Convert Date to String using a specific date format
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let dateString = dateFormatter.string(from: date)
                    json[attributeName] = dateString
                } else if let data = attributeValue as? Data {
                    // Convert Data to Base64-encoded String
                    let base64String = data.base64EncodedString()
                    json[attributeName] = base64String
                } else {
                    json[attributeName] = attributeValue
                }
            }
        }
        
        for relationship in entity.relationshipsByName {
            let relationshipName = relationship.key
            if let relationshipValue = self.value(forKey: relationshipName) as? NSManagedObject {
                json[relationshipName] = try relationshipValue.jsonObject()
            }
        }
        
        return json
    }
}
