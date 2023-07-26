//
//  ProductsViewModel.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-20.
//

import Foundation
import UIKit

class ProductsViewModel {
    
    var products = [Product]()
    var displayMode: DisplayMode?
    var sortOrder: SortOrder?
    var mMode: ViewMode = .view
    let manager = CoreDataManager.shared
    var selectedIndexPath: [IndexPath: Bool] = [:]
    var allAreSelected = false
    var showAlert: ((String) -> Void)?
    var onOk: (() -> Void)?
    var onCancel: (() -> Void)?
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: nil, action: nil)
        return barButtonItem
    }()
    lazy var rightBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: nil, action: nil)
        return barButtonItem
    }()
    lazy var leftBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.2x2"),style: .plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    func toggleDisplayMode() {
        self.displayMode = displayMode == .grid ? .list : .grid
    }
    
    func sortProducts() {
        switch sortOrder {
        case .name:
            products.sort {
                $0.pName ?? "" < $1.pName ?? ""
            }
        case .price:
            products.sort {
                $0.pPrice < $1.pPrice
            }
        case .quantity:
            products.sort {
                $0.pQty < $1.pQty
            }
        case .dateCreated:
            products.sort {
                $0.pDateCreated ?? Date() < $1.pDateCreated ?? Date()
            }
        case .none:
            products.sort {
                $0.pName ?? "" < $1.pName ?? ""
            }
        }
    }
    
    func fetchProducts() {
        products = manager.fetchProducts()
    }
    
    func toggleSortOrder () {
        switch sortOrder {
        case .name:
            sortOrder = .price
        case .price:
            sortOrder = .quantity
        case .quantity:
            sortOrder = .dateCreated
        case .dateCreated:
            sortOrder = .name
        case .none:
            sortOrder = .name
        }
    }
    
    func notificationAnimation (uiLabel: UILabel, uiBackground: UIView) {
        uiLabel.isHidden = false
        uiBackground.isHidden = false
        animateLbl(y: 0, lbl: uiLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            uiLabel.isHidden = true
            uiBackground.isHidden = true
        }
    }
    
    func animateLbl(y: CGFloat, lbl: UILabel) {
        lbl.transform = CGAffineTransform(translationX: 0, y: -500)
        UIView.animate(withDuration: 0.3) {
            lbl.transform = CGAffineTransform(translationX: 0, y: y)
        }
    }
    
    func saveDisplayMode() {
        if let currentMode = displayMode {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "DisplayMode")
        }
    }
    
    func loadDisplayMode() {
        if let savedMode = UserDefaults.standard.string(forKey: "DisplayMode") {
            displayMode = DisplayMode(rawValue: savedMode)
        } else {
            displayMode = .grid
        }
    }
    
    func saveSortOrder() {
        if let currentSortOrder = sortOrder {
            UserDefaults.standard.set(currentSortOrder.rawValue, forKey: "SortOrder")
        }
    }
    
    func loadSortOrder() {
        if let savedSortOrder = UserDefaults.standard.string(forKey: "SortOrder") {
            sortOrder = SortOrder(rawValue: savedSortOrder)
        } else {
            sortOrder = .name
        }
    }
    
    func setupView(cv: UICollectionView, tv: UITableView) {
        loadDisplayMode()
        loadSortOrder()
        sortProducts()
        
        if displayMode == .grid {
            cv.isHidden = false
            tv.isHidden = true
        } else {
            cv.isHidden = true
            tv.isHidden = false
        }
    }
    
    func setupMode(cv: UICollectionView, tv: UITableView) {
        switch mMode {
        case .view:
            for (key, value) in selectedIndexPath {
                if value {
                    cv.deselectItem(at: key, animated: true)
                    tv.deselectRow(at: key, animated: true)
                }
            }
            
            selectedIndexPath.removeAll()
            rightBarButton.image = UIImage(systemName: "arrow.up.arrow.down")
            leftBarButton.image = displayMode == .grid ? UIImage(systemName: "list.bullet") : UIImage(systemName: "rectangle.grid.2x2")
            selectBarButton.title = "Select"
            cv.allowsMultipleSelection = false
            tv.allowsMultipleSelection = false
            allAreSelected = false
        case .select:
            selectBarButton.title = "Cancel"
            rightBarButton.image = UIImage(systemName: "checklist.unchecked")
            leftBarButton.image = UIImage(systemName: "trash")
            cv.allowsMultipleSelection = true
            tv.allowsMultipleSelection = true
        }
    }
    
    func rightBarButtonTapped(cv: UICollectionView, tv: UITableView, notifLbl: UILabel, notifBck: UIView) {
        switch mMode {
        case .view:
            toggleSortOrder()
            notifLbl.text = sortOrder?.rawValue
            notificationAnimation(uiLabel: notifLbl, uiBackground: notifBck)
            sortProducts()
            cv.reloadData()
            tv.reloadData()
        case .select:
            selectAllCell()
            cv.reloadData()
            tv.reloadData()
            
            if allAreSelected {
                rightBarButton.image = UIImage(systemName: "checklist.unchecked")
                notifLbl.text = "All unselected!"
                notificationAnimation(uiLabel: notifLbl, uiBackground: notifBck)
                allAreSelected =  !allAreSelected
            } else {
                rightBarButton.image = UIImage(systemName: "checklist.checked")
                notifLbl.text = "All selected!"
                notificationAnimation(uiLabel: notifLbl, uiBackground: notifBck)
                allAreSelected = !allAreSelected
            }
            
            
        }
        
    }
    
    func leftBarButtonTapped(cv: UICollectionView, tv: UITableView, notifLbl: UILabel, notifBck: UIView) {
        if mMode == .view {
            toggleDisplayMode()
            if displayMode == .grid {
                cv.isHidden = false
                tv.isHidden = true
                leftBarButton.image = UIImage(systemName: "list.bullet")
                notifLbl.text = "Grid View"
            } else {
                cv.isHidden = true
                tv.isHidden = false
                leftBarButton.image = UIImage(systemName: "rectangle.grid.2x2")
                notifLbl.text = "List View"
            }
            notificationAnimation(uiLabel: notifLbl, uiBackground: notifBck)
        } else {
            if selectedIndexPath.contains(where: {$0.value == true}) {
                showAlert?("Are you sure you want to delete all selected products?")
                
                onOk = {
                    var deleteNeededIndexPaths: [IndexPath] = []
                    for (key, value) in self.selectedIndexPath {
                        if value {
                            deleteNeededIndexPaths.append(key)
                        }
                    }
                    for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
                        self.manager.deleteProduct(self.products[i.item])
                        self.products.remove(at: i.item)
                    }
                    cv.deleteItems(at: deleteNeededIndexPaths)
                    tv.deleteRows(at: deleteNeededIndexPaths, with: .fade)
                    self.selectedIndexPath.removeAll()
                    self.manager.save()
                    if self.products.isEmpty {
                        self.mMode = .view
                        self.selectBarButton.isEnabled = false
                        self.setupMode(cv: cv, tv: tv)
                    }
                }
            }
        }
    }
    
    func selectAllCell() {
        if !allAreSelected {
            for i in 0..<products.count {
                let indexPath = IndexPath(item: i, section: 0)
                selectedIndexPath[indexPath] = true
            }
        } else {
            selectedIndexPath.removeAll()
        }
    }
    
}
