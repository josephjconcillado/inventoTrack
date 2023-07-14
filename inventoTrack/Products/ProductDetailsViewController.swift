//
//  ProductDetailsViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import Foundation
import UIKit

protocol ProductDetailsViewControllerDelegate: AnyObject {
    func reloadData()
}

class ProductDetailsViewController: UIViewController, UITextFieldDelegate, BarcodeScannerViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var barcodeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    
    @IBOutlet weak var barcodeTF: UITextField!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var barcodeScanBtn: UIButton!
    
    @IBOutlet var popOverView: UIView!
    @IBOutlet weak var dollarSymLbl: UILabel!
    
    var selectedIndex: Int!
    var delegate: ProductDetailsViewControllerDelegate?
    var capturedImage: UIImage?
    var activeTextField: UITextField?
    var viewStateChanged = false
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.reloadData()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeTextField = activeTextField else {
            return
        }
        
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.view)
        let textFieldMaxY = textFieldFrame.maxY
        
        let keyboardY = self.view.frame.height - keyboardSize.height
        
        let offset = textFieldMaxY - keyboardY + 70 // Adjust the offset as per your preference
        
        if offset > 0 {
            view.frame.origin.y -= offset
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        self.view.endEditing(true)
        // Do not add a line break
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "barcodeScannerSegue" {
            if let vc = segue.destination as? BarcodeScannerViewController {
                vc.delegate = self
            }
        }
        
    }
    
    func didFindScannedText(text: String) {
        enterTextField(barcodeTF)
        barcodeTF.text = text
        barcodeTF.becomeFirstResponder()
        checkForm()
    }
    
    @IBAction func barcodeScanner2Btn(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            performSegue(withIdentifier: "barcodeScannerSegue", sender: nil)
        } else {
            self.showAlert(withTitle: "inventoTrack",message: "There seems to be a problem with the camera on your device.")
        }
    }
    
    func enterTextField(_ textField: UITextField){
        UIView.animate(withDuration: 0.3){
            //            style
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.systemGreen.cgColor
            //            move
            let transpose = CGAffineTransform(translationX: -25, y: -32)
            let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            if textField.accessibilityIdentifier == "barcode" {
                self.barcodeLbl.textColor = .systemGreen
                if !textField.hasText{
                    self.barcodeLbl.transform = transpose.concatenating(scale)
                }
                
            } else if textField.accessibilityIdentifier == "name" {
                self.nameLbl.textColor = .systemGreen
                if !textField.hasText{
                    self.nameLbl.transform = transpose.concatenating(scale)
                }
                
            } else if textField.accessibilityIdentifier == "description" {
                self.descriptionLbl.textColor = .systemGreen
                if !textField.hasText{
                    self.descriptionLbl.transform = transpose.concatenating(scale)
                }
                
            } else if textField.accessibilityIdentifier == "quantity" {
                self.qtyLbl.textColor = .systemGreen
                if !textField.hasText{
                    self.qtyLbl.transform = transpose.concatenating(scale)
                }
                
            } else {
                self.priceLbl.textColor = .systemGreen
                
                if !textField.hasText{
                    self.priceLbl.transform = transpose.concatenating(scale)
                    self.dollarSymLbl.isHidden = false
                }
            }
        }
    }
    
    func initTextField(){
        if(barcodeTF.hasText){
            let transpose = CGAffineTransform(translationX: -25, y: -32)
            let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.barcodeLbl.transform = transpose.concatenating(scale)
            self.nameLbl.transform = transpose.concatenating(scale)
            self.descriptionLbl.transform = transpose.concatenating(scale)
            self.qtyLbl.transform = transpose.concatenating(scale)
            self.priceLbl.transform = transpose.concatenating(scale)
            self.dollarSymLbl.isHidden = false
        } else {
            let transpose = CGAffineTransform(translationX: 0, y: 0)
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            self.barcodeLbl.transform = transpose.concatenating(scale)
            self.nameLbl.transform = transpose.concatenating(scale)
            self.descriptionLbl.transform = transpose.concatenating(scale)
            self.qtyLbl.transform = transpose.concatenating(scale)
            self.priceLbl.transform = transpose.concatenating(scale)
            self.dollarSymLbl.isHidden = true
        }
        barcodeTF.setLeftPaddingPoints(5)
        barcodeTF.setRightPaddingPoints(30)
        nameTF.setSidePaddingPoints(5)
        descriptionTF.setSidePaddingPoints(5)
        qtyTF.setSidePaddingPoints(5)
        priceTF.setSidePaddingPoints(5)
    }
    
    func enableTextField(){
        if nameTF.isEnabled {
            barcodeTF.isEnabled = !barcodeTF.isEnabled
            nameTF.isEnabled = !nameTF.isEnabled
            descriptionTF.isEnabled = !descriptionTF.isEnabled
            qtyTF.isEnabled = !qtyTF.isEnabled
            priceTF.isEnabled = !priceTF.isEnabled
            barcodeScanBtn.isEnabled = !barcodeScanBtn.isEnabled
            imageView.isUserInteractionEnabled = !imageView.isUserInteractionEnabled
            
            barcodeTF.backgroundColor = .systemGray5
            nameTF.backgroundColor = .systemGray5
            descriptionTF.backgroundColor = .systemGray5
            qtyTF.backgroundColor = .systemGray5
            priceTF.backgroundColor = .systemGray5
        } else {
            barcodeTF.isEnabled = !barcodeTF.isEnabled
            nameTF.isEnabled = !nameTF.isEnabled
            descriptionTF.isEnabled = !descriptionTF.isEnabled
            qtyTF.isEnabled = !qtyTF.isEnabled
            priceTF.isEnabled = !priceTF.isEnabled
            barcodeScanBtn.isEnabled = !barcodeScanBtn.isEnabled
            imageView.isUserInteractionEnabled = !imageView.isUserInteractionEnabled
            
            barcodeTF.backgroundColor = .systemGray6
            nameTF.backgroundColor = .systemGray6
            descriptionTF.backgroundColor = .systemGray6
            qtyTF.backgroundColor = .systemGray6
            priceTF.backgroundColor = .systemGray6
        }
        
    }
    
    func leaveTextField(_ textField: UITextField){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options:[]){
            //            textField.layer.borderWidth = 0.2
            textField.layer.cornerRadius = 5
            let transpose = CGAffineTransform(translationX: 0, y: 0)
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            
            if textField.accessibilityIdentifier == "barcode"{
                if !textField.hasText{
                    self.barcodeLbl.transform = transpose.concatenating(scale)
                    self.barcodeLbl.textColor = .systemRed
                    self.barcodeTF.layer.borderColor = UIColor.systemRed.cgColor
                    self.shakeIt(textField)
                } else {
                    self.barcodeLbl.textColor = .systemGray2
                    self.barcodeTF.layer.borderColor = UIColor.systemGray5.cgColor
                }
                
            } else if textField.accessibilityIdentifier == "name"{
                if !textField.hasText{
                    self.nameLbl.transform = transpose.concatenating(scale)
                    self.nameLbl.textColor = .systemRed
                    self.nameTF.layer.borderColor = UIColor.systemRed.cgColor
                    self.shakeIt(textField)
                } else {
                    self.nameLbl.textColor = .systemGray2
                    self.nameTF.layer.borderColor = UIColor.systemGray5.cgColor
                }
                
            } else if textField.accessibilityIdentifier == "description"{
                if !textField.hasText{
                    self.descriptionLbl.transform = transpose.concatenating(scale)
                    self.descriptionLbl.textColor = .systemRed
                    self.descriptionTF.layer.borderColor = UIColor.systemRed.cgColor
                    self.shakeIt(textField)
                } else {
                    self.descriptionLbl.textColor = .systemGray2
                    self.descriptionTF.layer.borderColor = UIColor.systemGray5.cgColor
                }
                
            } else if textField.accessibilityIdentifier == "quantity"{
                if !textField.hasText{
                    self.qtyLbl.transform = transpose.concatenating(scale)
                    self.qtyLbl.textColor = .systemRed
                    self.qtyTF.layer.borderColor = UIColor.systemRed.cgColor
                    self.shakeIt(textField)
                } else {
                    self.qtyLbl.textColor = .systemGray2
                    self.qtyTF.layer.borderColor = UIColor.systemGray5.cgColor
                }
                
            } else{
                if !textField.hasText{
                    self.priceLbl.transform = transpose.concatenating(scale)
                    self.priceLbl.textColor = .systemRed
                    self.priceTF.layer.borderColor = UIColor.systemRed.cgColor
                    self.dollarSymLbl.isHidden = true
                    self.shakeIt(textField)
                } else {
                    self.priceLbl.textColor = .systemGray2
                    self.priceTF.layer.borderColor = UIColor.systemGray5.cgColor
                    self.dollarSymLbl.isHidden = false
                }
            }
        }
    }
    
    @IBAction func textFieldEditBegin(_ sender: UITextField) {
        activeTextField = sender
        enterTextField(sender)
    }
    
    @IBAction func textFieldEditEnd(_ sender: UITextField) {
        activeTextField = nil
        view.frame.origin.y = 0
        leaveTextField(sender)
    }
    
    @IBAction func dismissKeyboard(_ sender: UIGestureRecognizer) {
        barcodeTF.resignFirstResponder()
        nameTF.resignFirstResponder()
        descriptionTF.resignFirstResponder()
        qtyTF.resignFirstResponder()
        priceTF.resignFirstResponder()
    }
    
    
    @IBAction func editProduct(_ sender: UIButton) {
        sender.isHidden = true
        saveBtn.isHidden = false
        saveBtn.isEnabled = false
        enableTextField()
    }
    
    @IBAction func saveProduct(_ sender: UIButton) {
        if viewStateChanged {
            product.pImage = imageView.image?.jpegData(compressionQuality: 0.1)
        }
        product.pName = nameTF.text!
        product.pDescription = descriptionTF.text!
        product.pBarcode = barcodeTF.text!
        product.pQty = Int32(qtyTF.text!)!
        product.pPrice = Double(priceTF.text!)!
        CoreDataManager.shared.save()
        enableTextField()
        
        let alert = UIAlertController(title: "inventoTrack", message: "Product Successfully Updated!", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true)
            sender.isHidden = true
            self.editBtn.isHidden = false
            self.editBtn.isEnabled = true
        })
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapImage(_ sender: UIButton) {
        let vc = UIImagePickerController()
        //        vc.modalPresentationStyle = .fullScreen
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                self.present(vc,animated: true)
            } else {
                self.showAlert(withTitle: "inventoTrack",message: "There seems to be a problem with the camera on your device.")
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {_ in
            vc.sourceType = .photoLibrary
            vc.allowsEditing = true
            vc.delegate = self
            self.present(vc,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.delegate = self
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let curImageView = imageView.image
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        // print out the image size as a test
        if curImageView != image {
            saveBtn.isEnabled = true
            viewStateChanged = true
        }
        imageView.image = image
        
        
    }
    
    @IBAction func changeTextField(_ textField: UITextField) {
        let identifier = textField.accessibilityIdentifier
        if identifier == "barcode" {
            if  !textField.hasText {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                barcodeLbl.textColor = .systemRed
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                barcodeLbl.textColor = .systemGreen
            }
        } else if identifier == "name" {
            if  !textField.hasText {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                nameLbl.textColor = .systemRed
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                nameLbl.textColor = .systemGreen
            }
        } else if identifier == "description"{
            if  !textField.hasText {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                descriptionLbl.textColor = .systemRed
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                descriptionLbl.textColor = .systemGreen
            }
        } else if identifier == "quantity" {
            let format = "SELF MATCHES %@"
            let pattern = #"\d{1,7}?$"#
            let value = textField.text!
            if !NSPredicate(format: format, pattern).evaluate(with: value) || !textField.hasText {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                textField.text = String(textField.text!.dropLast())
                qtyLbl.textColor = .systemRed
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                qtyLbl.textColor = .systemGreen
            }
        } else {
            let format = "SELF MATCHES %@"
            let pattern = #"\d*\.?(?:\d{1,2})?$"#
            let value = textField.text!
            if !NSPredicate(format: format, pattern).evaluate(with: value) || !textField.hasText{
                textField.layer.borderColor = UIColor.systemRed.cgColor
                textField.text = String(textField.text!.dropLast())
                priceLbl.textColor = .systemRed
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                priceLbl.textColor = .systemGreen
            }
        }
        checkForm()
    }
    
    func shakeIt(_ textField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x:textField.center.x - 5, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:textField.center.x + 5, y: textField.center.y))
        textField.layer.add(animation,forKey: "position")
    }
    func checkForm() {
        if !barcodeTF.text!.isEmpty && !nameTF.text!.isEmpty &&  !descriptionTF.text!.isEmpty &&  !qtyTF.text!.isEmpty &&  !priceTF.text!.isEmpty  {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
    }
    
    func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
}

// Extension for UITextfield Left/Right Padding
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func setSidePaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
