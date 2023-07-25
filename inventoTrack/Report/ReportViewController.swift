//
//  ReportViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit
import DGCharts

class ReportViewController: UIViewController {
    
    @IBOutlet weak var chartView: PieChartView!
    //    @IBOutlet weak var pieChart: PieChartView!
    
    private var allProducts: [Product] = [] {
        didSet {
            filteredProducts = allProducts
        }
    }
    private var filteredProducts: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
    
            allProducts = CoreDataManager.shared.fetchProducts()
    
            var entries = [ChartDataEntry]()
            for value in filteredProducts {
                entries.append(PieChartDataEntry(value: Double(value.pQty), label: value.pName))
            }
    
            let numberOfItems = entries.count
                    let legendHeight = CGFloat(30 * numberOfItems) // Assuming each legend item has a height of 30 pixels
    
                    // Adjust the chart view frame to fit the legend
            chartView.frame.size.height += legendHeight
    //        chartView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
            chartView.center = view.center
            chartView.centerText = "InventoTrack"
            chartView.drawEntryLabelsEnabled = false
            chartView.legendRenderer.legend?.orientation = .vertical
    //        chartView.legendRenderer.legend?.horizontalAlignment = .left
    
            chartView.animate(xAxisDuration: 1)
            view.addSubview(chartView)
    
    
    
            let set  = PieChartDataSet(entries: entries, label: "")
            set.colors = ChartColorTemplates.colorful()
            let data = PieChartData(dataSet: set)
            chartView.data = data
    
        }
    
    @IBAction func saveReport(_ sender: Any) {
        print("Start exporting...")
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let file_name = "My Inventory Report.csv"
        //        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file_name)
        let path = documentsDirectory.appendingPathComponent(file_name)
        var csvHeader = "Barcode,Product,Description,Quantity,Price\n"
        
        for product in filteredProducts {
            csvHeader.append("\(product.pBarcode!),\(product.pName!),\(product.pDescription!),\(product.pQty),\(product.pPrice)\n")
        }
        
        do {
            try csvHeader.write(to: path, atomically: true, encoding: .utf8)
            let exportSheet = UIActivityViewController(activityItems: [path as Any], applicationActivities: nil)
            exportSheet.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, error) in
                
                if completed {
                    self?.showAlert(withTitle: "inventoTrack", message: "Report Successfully Saved!")
                }
                
                // Dismiss the view controller when sharing/exporting is completed or canceled
                self?.deleteTempFile(url: path)
            }
            self.present(exportSheet, animated: true, completion: nil)
            
        }catch {
            print("Error")
        }
    }
    
    func deleteTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Removed Temp JSON File")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
}
