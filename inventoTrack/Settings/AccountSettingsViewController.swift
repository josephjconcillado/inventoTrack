//
//  AccountSettingsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit
import GoogleSignIn

protocol AccountSettingsViewControllerDelegate: AnyObject {
    func reloadView(identifier: String)
}

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var welcomeLbl: UILabel!
    
    var delegate:AccountSettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.reloadView(identifier: "account")
    }
    
    
    @IBAction func signIn(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self,hint: "Sign in now",additionalScopes: ["https://www.googleapis.com/auth/drive.file"]) { signInResult, error in
            guard error == nil else { return }
            self.welcomeLbl.isHidden = false
            self.label.text = signInResult?.user.profile?.email
            self.label.text = (self.label.text ?? "") + "\n\nYour inventory data can now be backed up to Google Drive for secure storage and easy access!"
            self.signInBtn.isHidden = true
            self.signOutBtn.isHidden = false
        }
        
    }
    @IBAction func signOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "inventoTrack", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            GIDSignIn.sharedInstance.signOut()
            self.checkUser()
        })
        alert.addAction(okayAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func checkUser() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                self.label.text = "Sign in now!\n\nBackup your data to Google Drive for secure storage and easy access."
                self.signInBtn.isHidden = false
                self.signOutBtn.isHidden = true
                self.welcomeLbl.isHidden = true
            } else {
                // Show the app's signed-in state.
                self.label.text = user?.profile?.email
                self.signInBtn.isHidden = true
                self.signOutBtn.isHidden = false
                self.welcomeLbl.isHidden = false
                self.label.text = (self.label.text ?? "") + "\n\nYour inventory data can now be backed up to Google Drive for secure storage and easy access!"
            }
        }
    }
    
}
