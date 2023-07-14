//
//  ProductsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

struct SortOption {
    let title: String
    let sortValue: String
}


class ProductsViewController: UIViewController, ProductDetailsViewControllerDelegate, AddProductViewControllerDelegate, UITableViewDelegate {
    
    enum Mode {
        case view
        case select
    }
    enum SelectedView {
        case collection
        case table
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //    var items: [ProductSample] = productDataSample
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "ProductCollectionViewCell"
    let productDetailsViewSegue = "productDetailsViewSegue"
    var selectedIndex: Int!
    
    
    private var allProducts: [Product] = [] {
        didSet {
            filteredProducts = allProducts
        }
    }
    private var filteredProducts: [Product] = []
    
    var sortOptions: [SortOption] = []
    var viewOption: [DisplayView] = []
    var sortOptionData: Sort!
    var currentSort: Int = 0
    var isToggled = false
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                for (key, value) in selectedIndexPath {
                    if value {
                        if isToggled {
                            collectionView.deselectItem(at: key, animated: true)
                        } else {
                            tableView.deselectRow(at: key, animated: true)
                        }
                    }
                }
                
                selectedIndexPath.removeAll()
                
                selectBarButton.title = "Select"
                navigationItem.leftBarButtonItem = nil
                collectionView.allowsMultipleSelection = false
                tableView.allowsMultipleSelection = false
                
            case .select:
                selectBarButton.title = "Cancel"
                navigationItem.leftBarButtonItems = [deleteBarButton,displayToggleBarButton]
                collectionView.allowsMultipleSelection = true
                tableView.allowsMultipleSelection = true
                checkItems()
            }
        }
    }
    
    
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(didSelectButtonClicked(_:)))
        return barButtonItem
    }()
    
    lazy var sortBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(didSortButtonClicked(_:)))
        barButtonItem.customView?.frame = CGRectMake(0, 0, 20, 20)
        return barButtonItem
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didDeleteButtonClicked(_:)))
        barButtonItem.customView?.frame = CGRectMake(0, 0, 20, 20)
        return barButtonItem
    }()
    
    lazy var displayToggleBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.2x2"), style: .plain, target: self, action: #selector(didToggleButtonClicked(_:)))
        barButtonItem.customView?.frame = CGRectMake(0, 0, 20, 20)
        return barButtonItem
    }()
    
    var selectedIndexPath: [IndexPath: Bool] = [:]
    var selectedItemIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sortOptions = [
            SortOption(title: "Sort By Name",sortValue: "pName"),
            SortOption(title: "Sort By Date",sortValue: "pDateCreated"),
            SortOption(title: "Sort By Price",sortValue: "pPrice"),
            SortOption(title: "Sort By Quantity",sortValue: "pQty"),
        ]
        fetchProductsFromStorage()
        setupBarButtonItems()
        setupCollectionView()
        checkItems()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewOption[0].viewOption = !isToggled
        CoreDataManager.shared.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == productDetailsViewSegue {
            if let vc = segue.destination as? ProductDetailsViewController {
                let item = sender as! Product
                vc.loadViewIfNeeded()
                vc.product = item
                vc.delegate = self
                vc.imageView.image = item.pImage == nil ? UIImage(systemName: "photo") : UIImage(data: item.pImage!)
                vc.barcodeTF.text = item.pBarcode
                vc.nameTF.text = item.pName
                vc.descriptionTF.text = item.pDescription
                vc.priceTF.text = String(item.pPrice)
                vc.qtyTF.text = String(item.pQty)
                vc.initTextField()
                vc.selectedIndex = selectedIndex
            }
        } else if segue.identifier == "addProductViewSegue" {
            if let vc = segue.destination as? AddProductViewController {
                vc.delegate = self
            }
        }
    }
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItems = [selectBarButton, sortBarButton]
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = displayToggleBarButton
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        
        if !isToggled {
            collectionView.isHidden = false
            tableView.isHidden = true
            isToggled = !isToggled
            displayToggleBarButton.image = UIImage(systemName: "list.bullet")
        } else {
            collectionView.isHidden = true
            tableView.isHidden = false
            isToggled = !isToggled
            displayToggleBarButton.image = UIImage(systemName: "rectangle.grid.2x2")
        }
    }
    
    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
    }
    
    @objc func didSortButtonClicked(_ sender: UIBarButtonItem) {
        if self.sortOptionData.sortOption < self.sortOptions.count - 1 {
            self.sortOptionData.sortOption += 1
        } else {
            self.sortOptionData.sortOption = 0
        }
        self.fetchProductsFromStorage()
        CoreDataManager.shared.save()
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
    @objc func didToggleButtonClicked(_ sender: UIBarButtonItem) {
        if !isToggled {
            collectionView.isHidden = false
            tableView.isHidden = true
            isToggled = !isToggled
            displayToggleBarButton.image = UIImage(systemName: "list.bullet")
        } else {
            collectionView.isHidden = true
            tableView.isHidden = false
            isToggled = !isToggled
            displayToggleBarButton.image = UIImage(systemName: "rectangle.grid.2x2")
        }
    }
    
    @objc func didDeleteButtonClicked(_ sender: UIBarButtonItem) {
        var deleteNeededIndexPaths: [IndexPath] = []
        for (key, value) in selectedIndexPath {
            if value {
                deleteNeededIndexPaths.append(key)
            }
        }
        
        for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
            CoreDataManager.shared.deleteProduct(filteredProducts[i.item])
            filteredProducts.remove(at: i.item)
        }
        
        collectionView.deleteItems(at: deleteNeededIndexPaths)
        tableView.deleteRows(at: deleteNeededIndexPaths, with: .fade)
        selectedIndexPath.removeAll()
        CoreDataManager.shared.save()
        checkItems()
    }
    @IBAction func addProductButton(_ sender: Any) {
        performSegue(withIdentifier: "addProductViewSegue", sender: nil)
    }
    
    func reloadData() {
        fetchProductsFromStorage()
        collectionView.reloadData()
        tableView.reloadData()
        checkItems()
    }
    
    func fetchProductsFromStorage() {
        var sortOptionsData = CoreDataManager.shared.fetchSortOption()
        
        if sortOptionsData.isEmpty {
            CoreDataManager.shared.initializeSortOption()
            CoreDataManager.shared.initializeViewOption()
            viewOption = CoreDataManager.shared.fetchViewOption()
            sortOptionsData = CoreDataManager.shared.fetchSortOption()
            sortOptionData = sortOptionsData[0]
        } else {
            viewOption = CoreDataManager.shared.fetchViewOption()
            sortOptionData = sortOptionsData[0]
        }
        allProducts = CoreDataManager.shared.fetchProducts(sortOption: sortOptions[Int(sortOptionData.sortOption)].sortValue)
        isToggled = viewOption[0].viewOption
    }
    
    func checkItems() {
        if filteredProducts.isEmpty {
            if mMode == .select {
                didSelectButtonClicked(selectBarButton)
            }
            selectBarButton.isEnabled = false
        } else {
            selectBarButton.isEnabled = true
        }
    }
    
}

extension ProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
        
        cell.imageView.image = filteredProducts[indexPath.item].pImage == nil ? UIImage(systemName: "photo") : UIImage(data: filteredProducts[indexPath.item].pImage!)
        cell.pLabel.text = filteredProducts[indexPath.item].pName
        cell.pQty.text = String(filteredProducts[indexPath.item].pQty)
        
        // Add a long-press gesture recognizer to the cell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if isToggled {
            if let cell = gestureRecognizer.view as? ProductCollectionViewCell {
                if let indexPath = collectionView.indexPath(for: cell) {
                    if gestureRecognizer.state == .began {
                        if mMode == .view {
                            didSelectButtonClicked(selectBarButton)
                            cell.highlightIndicator.isHidden = false
                            cell.selectIndicator.isHidden = false
                            //                        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                            //                        dictionarySelectedIndecPath[indexPath] = true
                        }
                    } else if gestureRecognizer.state == .ended {
                        if mMode == .select {
                            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                            selectedIndexPath[indexPath] = true
                        }
                    }
                }
            }
        } else {
            if let cell = gestureRecognizer.view as? ProductTableViewCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    if gestureRecognizer.state == .began {
                        if mMode == .view {
                            didSelectButtonClicked(selectBarButton)
                            cell.highlightIndicator.isHidden = false
                            cell.selectIndicator.isHidden = false
                            //                        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                            //                        dictionarySelectedIndecPath[indexPath] = true
                        }
                    } else if gestureRecognizer.state == .ended {
                        if mMode == .select {
                            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                            selectedIndexPath[indexPath] = true
                        }
                    }
                }
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            let item = filteredProducts[indexPath.item]
            selectedIndex = indexPath.item
            selectedItemIndex = indexPath
            performSegue(withIdentifier: productDetailsViewSegue, sender: item)
            
        case .select:
            selectedIndexPath[indexPath] = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mMode == .select {
            selectedIndexPath[indexPath] = false
        }
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
}

extension ProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        
        cell.tableImageView.image = filteredProducts[indexPath.item].pImage == nil ? UIImage(systemName: "photo") : UIImage(data: filteredProducts[indexPath.item].pImage!)
        cell.nameTableLbl.text = filteredProducts[indexPath.item].pName
        cell.barcodeTableLbl.text = filteredProducts[indexPath.item].pBarcode
        cell.descriptionTableLbl.text = filteredProducts[indexPath.item].pDescription
        cell.quantityTableLbl.text = "Quantity: " + String(filteredProducts[indexPath.item].pQty)
        cell.priceTableLbl.text = "Price: $ " + String(filteredProducts[indexPath.item].pPrice)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            
            tableView.deselectRow(at: indexPath, animated: true)
            let row = filteredProducts[indexPath.row]
            selectedIndex = indexPath.row
            selectedItemIndex = indexPath
            performSegue(withIdentifier: productDetailsViewSegue, sender: row)
            
        case .select:
            
            selectedIndexPath[indexPath] = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if mMode == .select {
            selectedIndexPath[indexPath] = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 // Adjust the height as per your requirements
    }
}
