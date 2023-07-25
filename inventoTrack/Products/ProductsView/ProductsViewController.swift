//
//  ProductsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

class ProductsViewController: UIViewController, ProductDetailsViewControllerDelegate, AddProductViewControllerDelegate, UITableViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notifLbl: UILabel!
    @IBOutlet weak var notifBck: UIView!
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let viewModel = ProductsViewModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItems()
        viewModel.fetchProducts()
        setupView()
        checkItems()
        notifLbl.isHidden = true
        notifBck.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.manager.save()
        viewModel.saveDisplayMode()
        viewModel.saveSortOrder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productDetailsViewSegue" {
            
            if let vc = segue.destination as? ProductDetailsViewController {
                if let item = sender as? Product {
                    vc.setup(product: item)
                    vc.delegate = self
                    
                }
            }
        } else if segue.identifier == "addProductViewSegue" {
            if let vc = segue.destination as? AddProductViewController {
                vc.delegate = self
            }
        }
    }
    
    @objc func didSelectTapped(_ sender: UIBarButtonItem) {
        viewModel.mMode = viewModel.mMode == .view ? .select : .view
        viewModel.setupMode(cv: collectionView, tv: tableView)
    }
    
    @objc func didRightBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.rightBarButtonTapped(cv: collectionView, tv: tableView,notifLbl: notifLbl,notifBck: notifBck)
    }
    
    @objc func didLeftBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.leftBarButtonTapped(cv: collectionView, tv: tableView, notifLbl: notifLbl, notifBck: notifBck)
        checkItems()
    }
    
    @IBAction func addProductButton(_ sender: Any) {
        performSegue(withIdentifier: "addProductViewSegue", sender: nil)
    }
    
    func reloadData() {
        viewModel.fetchProducts()
        viewModel.sortProducts()
        collectionView.reloadData()
        tableView.reloadData()
        checkItems()
    }
    
    func checkItems() {
        if viewModel.products.isEmpty {
            if viewModel.mMode == .select {
                didSelectTapped(viewModel.selectBarButton)
            }
            viewModel.selectBarButton.isEnabled = false
        } else {
            viewModel.selectBarButton.isEnabled = true
        }
    }
    
    func setupBarButtonItems() {
        viewModel.selectBarButton.target = self
        viewModel.selectBarButton.action = #selector(didSelectTapped(_:))
        viewModel.rightBarButton.target = self
        viewModel.rightBarButton.action = #selector(didRightBarButtonTapped(_:))
        viewModel.leftBarButton.target = self
        viewModel.leftBarButton.action = #selector(didLeftBarButtonTapped(_:))
        
        navigationItem.rightBarButtonItems = [viewModel.selectBarButton, viewModel.rightBarButton]
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = viewModel.leftBarButton
    }
    
    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        viewModel.setupView(cv: collectionView, tv: tableView)
        viewModel.showAlert = { alertText in
            let alert = UIAlertController(title: "inventoTrack", message: alertText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {_ in
                self.viewModel.onOk?()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

