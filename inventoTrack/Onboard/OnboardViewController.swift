//
//  OnboardViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

// Onboard Data Model Struct for displaying the slides
struct OnboardSlide {
    let title: String
    let description: String
    let image: UIImage
}

class OnboardViewController: UIViewController {
    
//    Link all Objects from the storyboard
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var onboardCollectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    

    var slides: [OnboardSlide] = []
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                getStartedBtn.isHidden = false
                nextBtn.isHidden = true
            } else {
                getStartedBtn.isHidden = true
                nextBtn.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        onboardCollectionView.delegate = self
        onboardCollectionView.dataSource = self
        
        slides = [
            OnboardSlide(title: "Easy Inventory Management", description: "Seamlessly add, edit, and organize your inventory items.", image: #imageLiteral(resourceName: "onboardImage1")),
            OnboardSlide(title: "Barcode Scanning", description: "Use your device's camera to quickly scan barcodes for efficient item entry.", image: #imageLiteral(resourceName: "onboardImage2")),
            OnboardSlide(title: "Product Photos", description: " Attach photos to your inventory items, making it easier to identify products visually.", image: #imageLiteral(resourceName: "onboardImage3")),
            OnboardSlide(title: "Google Drive Backup", description: "Safely store your data in the google drive and access it from multiple devices.", image: #imageLiteral(resourceName: "onboardImage4")),
            OnboardSlide(title: "Reports and Analytics", description: "Gain insights into your inventory performance and make informed decisions.", image: #imageLiteral(resourceName: "onboardImage5")),
        ]
        
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            // Update the properties you want to animate
            self.appLogo.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    @IBAction func nxtBtn(_ sender: Any) {
        if currentPage == slides.count - 1 {
            
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            onboardCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension OnboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardCollectionViewCell", for: indexPath) as! OnboardCollectionViewCell
        cell.setup(slides[indexPath.row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
