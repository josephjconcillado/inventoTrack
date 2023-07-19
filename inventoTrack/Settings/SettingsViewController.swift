//
//  SettingsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit
import GoogleSignIn
//import GTMSessionFetcher

class SettingsViewController: UIViewController, AccountSettingsViewControllerDelegate, AboutSettingsViewControllerDelegate {
    
    var expandedSections: Set<Int> = []
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //    916230421611-96pbr9dh26bruk2v03e1emknutioqu6n.apps.googleusercontent.com
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var feedbackBtn: UIButton!
    @IBOutlet var settingsLabels: [UILabel]!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            // Update the properties you want to animate
            self.backgroundImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func tappedBtn(_ sender: UIButton) {
//        guard let tappedLabel = gesture.view as? UILabel else { return }
        // Handle the tap gesture here
        if sender == accountBtn {
            animateLbl(y: -500, btn: sender)
            accountBtn.isHidden = true
            aboutBtn.isHidden = true
            feedbackBtn.isHidden = true
            performSegue(withIdentifier: "account", sender: nil)
        } else if sender == aboutBtn {
            animateLbl(y: -500, btn: sender)
            accountBtn.isHidden = true
            aboutBtn.isHidden = true
            feedbackBtn.isHidden = true
            performSegue(withIdentifier: "about", sender: nil)
        } else if sender == feedbackBtn {
            guard let emailURL = URL(string: "mailto:jconcillado@jcdevworks.website?subject=Feedback&body=Hello%20there") else {
                // Handle URL initialization failure
                showAlert(withTitle: "Error", message: "Failed to create email URL.")
                return
            }
            
            guard UIApplication.shared.canOpenURL(emailURL) else {
                // Handle inability to open the URL
                showAlert(withTitle: "Error", message: "Unable to open email app. Set default mail app in the settings.")
                return
            }
            
            UIApplication.shared.open(emailURL, options: [:]) { success in
                if !success {
                    // Handle failure to open the URL
                    self.showAlert(withTitle: "Error", message: "Failed to open email app. Set default mail app in the settings.")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "account" {
            if let vc = segue.destination as? AccountSettingsViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "about" {
            if let vc = segue.destination as? AboutSettingsViewController {
                vc.delegate = self
            }
        }
    }
    
    
    func reloadView(identifier: String) {
        accountBtn.isHidden = false
        aboutBtn.isHidden = false
        feedbackBtn.isHidden = false
        if identifier == "account" {
            animateLbl(y: 0, btn: accountBtn)
        } else if identifier == "about" {
            animateLbl(y: 0, btn: aboutBtn)
        } else if identifier == "feedback" {
            animateLbl(y: 0, btn: feedbackBtn)
        }
    }
    
    func animateLbl(y: CGFloat, btn: UIButton) {
        //        let desiredY = (view.bounds.height * y)/2
        UIView.animate(withDuration: 0.3) {
            btn.transform = CGAffineTransform(translationX: 0, y: y)
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
