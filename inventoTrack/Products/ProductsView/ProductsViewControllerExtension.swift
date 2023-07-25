//
//  ProductsViewControllerExtension.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-22.
//

import Foundation
import UIKit

extension ProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.imageView.image = viewModel.products[indexPath.item].pImage == nil ? UIImage(systemName: "photo") : UIImage(data: viewModel.products[indexPath.item].pImage!)
        cell.pLabel.text = viewModel.products[indexPath.item].pName
        cell.pQty.text = String(viewModel.products[indexPath.item].pQty)
        
        
        if viewModel.selectedIndexPath[indexPath] == true {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        // Add a long-press gesture recognizer to the cell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.mMode {
        case .view:
            self.collectionView.deselectItem(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "productDetailsViewSegue", sender: viewModel.products[indexPath.item])
            
        case .select:
            viewModel.selectedIndexPath[indexPath] = true
//            self.tableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if viewModel.mMode == .select {
            viewModel.selectedIndexPath[indexPath] = false
        }
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 85, height: 120)
    }
}

extension ProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        
        cell.tableImageView.image = viewModel.products[indexPath.item].pImage == nil ? UIImage(systemName: "photo") : UIImage(data: viewModel.products[indexPath.item].pImage!)
        cell.nameTableLbl.text = viewModel.products[indexPath.item].pName
        cell.barcodeTableLbl.text = viewModel.products[indexPath.item].pBarcode
        cell.descriptionTableLbl.text = viewModel.products[indexPath.item].pDescription
        cell.quantityTableLbl.text = "Quantity: " + String(viewModel.products[indexPath.item].pQty)
        cell.priceTableLbl.text = "Price: $ " + String(viewModel.products[indexPath.item].pPrice)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        if viewModel.selectedIndexPath[indexPath] == true {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.mMode {
        case .view:
            
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "productDetailsViewSegue", sender: viewModel.products[indexPath.row])
            
        case .select:
            print("selected rows after selection: ", tableView.indexPathsForSelectedRows?.count ?? 0)
            viewModel.selectedIndexPath[indexPath] = true
            self.collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if viewModel.mMode == .select {
            print("selected rows after deselection: ", tableView.indexPathsForSelectedRows?.count ?? 0)
            viewModel.selectedIndexPath[indexPath] = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }

}

extension ProductsViewController {
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if viewModel.displayMode == .grid {
            if let cell = gestureRecognizer.view as? ProductCollectionViewCell {
                if let indexPath = collectionView.indexPath(for: cell) {
                    if gestureRecognizer.state == .began {
                        if viewModel.mMode == .view {
                            didSelectTapped(viewModel.selectBarButton)
                            cell.highlightIndicator.isHidden = false
                            cell.selectIndicator.isHidden = false
                        }
                    } else if gestureRecognizer.state == .ended {
                        if viewModel.mMode == .select {
                            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                            viewModel.selectedIndexPath[indexPath] = true
                        }
                    }
                }
            }
        } else {
            if let cell = gestureRecognizer.view as? ProductTableViewCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    if gestureRecognizer.state == .began {
                        if viewModel.mMode == .view {
                            didSelectTapped(viewModel.selectBarButton)
                            cell.highlightIndicator.isHidden = false
                            cell.selectIndicator.isHidden = false
                        }
                    } else if gestureRecognizer.state == .ended {
                        if viewModel.mMode == .select {
                            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                            viewModel.selectedIndexPath[indexPath] = true
                        }
                    }
                }
            }
            
        }
    }
}

