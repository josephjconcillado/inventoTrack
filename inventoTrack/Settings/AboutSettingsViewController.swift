//
//  AboutSettingsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

protocol AboutSettingsViewControllerDelegate: AnyObject {
    func reloadView(identifier: String)
}

class AboutSettingsViewController: UIViewController {
    
    var delegate: AboutSettingsViewControllerDelegate?

    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        aboutTextView.text = "App Description\nInventoTrack is a simple and intuitive inventory management app designed to help you effortlessly track and manage your inventory. Whether you're a small business owner, a warehouse manager, or simply need to keep track of your personal belongings, InventoTrack is here to make your life easier.\n\nKey Features \nEasy Inventory Management: Seamlessly add, edit, and organize your inventory items.\nProduct Photos: Attach photos to your inventory items, making it easier to identify products visually.\nBarcode Scanning: Use your device's camera to quickly scan barcodes for efficient item entry.\nGoogle Drive Backup: Safely store your data in the google drive and access it from multiple devices.\nReports and Analytics: Gain insights into your inventory performance and make informed decisions.\n\nContact Information\nEmail: jconcillado@jcdevworks.website\nWebsite: https://jcdevworks.website\nPhone: (647)795-0796\n\nVersion Information:\nCurrent Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")\nRelease Date: 2023/07/27\nLatest Updates: Initial Release \n\nCredits \nIcons:\nIcons8 (https://icons8.com). All icons are used under license and their extraction and reuse are prohibited without explicit permission from Icons8.\nImages:\nonboardImage1 by storyset on Freepik (https://www.freepik.com/free-vector/checking-boxes-concept-illustration_8832806.htm)\nonboardImage2 by storyset on Freepik (https://www.freepik.com/free-vector/barcode-concept-illustration_17195481.htm)\nonboardImage3 by storyset on Freepik (https://www.freepik.com/free-vector/image-viewer-concept-illustration_12464559.htm)\nonboardImage4 by storyset on Freepik (https://www.freepik.com/free-vector/image-upload-concept-illustration_6189389.htm)\nonboardImage5 by storyset on Freepik (https://www.freepik.com/free-vector/spreadsheets-concept-illustration_6450135.htm)"
        
        aboutTextView.dataDetectorTypes = .link
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.reloadView(identifier: "about")
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }
}
