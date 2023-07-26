//
//  ProductCollectionViewCell.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectIndicator: UIImageView!
    @IBOutlet weak var pLabel: UILabel!
    @IBOutlet weak var pQty: UILabel!
    
    
//    This is used when an Item is tapped to show check and highlight
    override var isHighlighted: Bool {
        didSet {
            
            highlightIndicator.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highlightIndicator.isHidden = !isSelected
            selectIndicator.isHidden = !isSelected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
