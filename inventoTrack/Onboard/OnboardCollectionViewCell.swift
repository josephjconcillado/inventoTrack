//
//  OnboardCollectionViewCell.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

class OnboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideDescriptionLbl: UILabel!
    
    func setup(_ slide: OnboardSlide) {
        slideImageView.image = slide.image
        slideTitleLbl.text = slide.title
        slideDescriptionLbl.text = slide.description
    }
}
