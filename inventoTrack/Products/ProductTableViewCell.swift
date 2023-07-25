//
//  ProductTableViewCell.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-14.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableImageView: UIImageView!
    @IBOutlet weak var nameTableLbl: UILabel!
    @IBOutlet weak var barcodeTableLbl: UILabel!
    @IBOutlet weak var descriptionTableLbl: UILabel!
    @IBOutlet weak var quantityTableLbl: UILabel!
    @IBOutlet weak var priceTableLbl: UILabel!
    
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            // Cell is selected, customize the appearance
            highlightIndicator.isHidden = false
            selectIndicator.isHidden = false
        } else {
            // Cell is not selected, reset the appearance
            highlightIndicator.isHidden = true
            selectIndicator.isHidden = true
        }
    }
    
}
