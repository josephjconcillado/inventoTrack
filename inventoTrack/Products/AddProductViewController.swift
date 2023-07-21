//
//  AddProductViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit

protocol AddProductViewControllerDelegate: AnyObject {
    func reloadData()
}

class AddProductViewController: UIViewController,BarcodeScannerViewControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
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
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var barcodeScanBtn: UIButton!
    @IBOutlet weak var dollarSymLbl: UILabel!
    @IBOutlet weak var tapToAddImageLbl: PaddingLabel!
    
    
    var delegate: ProductDetailsViewControllerDelegate?
    var activeTextField: UITextField?
    var currentImage: UIImageView?
    var viewStateChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTF()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        currentImage = imageView
        
        self.nameTF.delegate = self
        self.barcodeTF.delegate = self
        self.descriptionTF.delegate = self
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeTextField = activeTextField else {
            return
        }
        
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.view)
        let textFieldMaxY = textFieldFrame.maxY
        
        let keyboardY = self.view.frame.height - keyboardSize.height
        
        let offset = textFieldMaxY - keyboardY + 10 // Adjust the offset as per your preference
        
        if offset > 0 {
            view.frame.origin.y -= offset
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.reloadData()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        self.view.endEditing(true)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "barcodeScannerSegue" {
            if let vc = segue.destination as? BarcodeScannerViewController {
                vc.delegate = self
            }
        }
    }
    
    func updateBeforeLabel(_ label: UILabel,_ textField: UITextField) {
        let transpose = CGAffineTransform(translationX: -25, y: -32)
        let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        label.textColor = .systemGreen
        if !textField.hasText{
            label.transform = transpose.concatenating(scale)
//            if label == dollarSymLbl {
//                dollarSymLbl.isHidden = false
//            }
        }
    }
    
    func enterTextField(_ textField: UITextField){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options:[]){
            //            style
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.systemGreen.cgColor
            //            move
            if textField.accessibilityIdentifier == "barcode" {
                self.updateBeforeLabel(self.barcodeLbl, textField)
            } else if textField.accessibilityIdentifier == "name" {
                self.updateBeforeLabel(self.nameLbl, textField)
            } else if textField.accessibilityIdentifier == "description" {
                self.updateBeforeLabel(self.descriptionLbl, textField)
            } else if textField.accessibilityIdentifier == "quantity" {
                self.updateBeforeLabel(self.qtyLbl, textField)
            } else {
                self.updateBeforeLabel(self.priceLbl, textField)
                self.dollarSymLbl.isHidden = false
            }
        }
    }
    
    func initTF(){
        let transpose = CGAffineTransform(translationX: 0, y: 0)
        let scale = CGAffineTransform(scaleX: 1, y: 1)
        self.barcodeLbl.transform = transpose.concatenating(scale)
        self.nameLbl.transform = transpose.concatenating(scale)
        self.descriptionLbl.transform = transpose.concatenating(scale)
        self.qtyLbl.transform = transpose.concatenating(scale)
        self.priceLbl.transform = transpose.concatenating(scale)
        barcodeTF.setLeftPaddingPoints(5)
        barcodeTF.setRightPaddingPoints(30)
        nameTF.setSidePaddingPoints(5)
        descriptionTF.setSidePaddingPoints(5)
        qtyTF.setSidePaddingPoints(5)
        priceTF.setSidePaddingPoints(5)
        addBtn.isEnabled = false
        imageView.image = UIImage(systemName: "photo")
        self.barcodeTF.text = ""
        self.nameTF.text = ""
        self.descriptionTF.text = ""
        self.qtyTF.text = ""
        self.priceTF.text = ""
    }
    
    func enableTextField(){
        barcodeTF.isEnabled = !barcodeTF.isEnabled
        nameTF.isEnabled = !nameTF.isEnabled
        descriptionTF.isEnabled = !descriptionTF.isEnabled
        qtyTF.isEnabled = !qtyTF.isEnabled
        priceTF.isEnabled = !priceTF.isEnabled
        if nameTF.isEnabled {
            barcodeTF.backgroundColor = .systemGray5
            nameTF.backgroundColor = .systemGray5
            descriptionTF.backgroundColor = .systemGray5
            qtyTF.backgroundColor = .systemGray5
            priceTF.backgroundColor = .systemGray5
        } else {
            barcodeTF.backgroundColor = .systemGray6
            nameTF.backgroundColor = .systemGray6
            descriptionTF.backgroundColor = .systemGray6
            qtyTF.backgroundColor = .systemGray6
            priceTF.backgroundColor = .systemGray6
        }
    }
    
    func updateAfterLabel(_ label: UILabel,_ textField: UITextField) {
        let transpose = CGAffineTransform(translationX: 0, y: 0)
        let scale = CGAffineTransform(scaleX: 1, y: 1)
        
        if !textField.hasText{
            label.transform = transpose.concatenating(scale)
            label.textColor = .systemRed
            if label == dollarSymLbl {
                dollarSymLbl.isHidden = true
                print("not hidding")
            }
        } else {
            label.textColor = .systemGray2
            if label == dollarSymLbl {
                dollarSymLbl.isHidden = false
                print("hidden")
            }
        }
    }
    
    func leaveTextField(_ textField: UITextField){
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options:[]){
            textField.layer.cornerRadius = 5
            if !textField.hasText {
                textField.layer.borderColor = UIColor.systemRed.cgColor
                if textField == self.priceTF {
                    self.dollarSymLbl.isHidden = true
                }
                self.shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGray5.cgColor
                if textField == self.priceTF {
                    self.dollarSymLbl.isHidden = false
                }
            }
            
            if textField.accessibilityIdentifier == "barcode"{
                self.updateAfterLabel(self.barcodeLbl, textField)
            } else if textField.accessibilityIdentifier == "name"{
                self.updateAfterLabel(self.nameLbl, textField)
            } else if textField.accessibilityIdentifier == "description"{
                self.updateAfterLabel(self.descriptionLbl, textField)
            } else if textField.accessibilityIdentifier == "quantity"{
                self.updateAfterLabel(self.qtyLbl, textField)
            } else{
                self.updateAfterLabel(self.priceLbl, textField)
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
    
    @IBAction func tapImage(_ sender: Any) {
        
        let vc = UIImagePickerController()
        
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
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        imageView.image = image
        viewStateChanged = true
        tapToAddImageLbl.isHidden = true
    }
    
    
    @IBAction func addProduct(_ sender: UIButton) {
    
//      let tfBarcode = String(Int.random(in: 1..<9999999999))
        
        let uploadImage = !viewStateChanged ? NSData() as Data : imageView.image?.jpegData(compressionQuality: 0.1)
        
        CoreDataManager.shared.createProduct(barcode: barcodeTF.text!, name: nameTF.text!, description: descriptionTF.text!, quantity: qtyTF.text!, price: priceTF.text!,image: uploadImage!)
        
        //        productData.append(ProductSample(barcode: tfBarcode,name: nameTF.text!, description: descriptionTF.text!, quantity: qtyTF.text!, price: priceTF.text!, image: uploadImage!))
        
        let alert = UIAlertController(title: "inventoTrack", message: "Product Successfully Added!", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alert.dismiss(animated: true)
            self.view.endEditing(true)
            self.initTF()
        })
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    func extendedChangeTextField(_ label: UILabel,_ textField: UITextField) {
        if  !textField.hasText {
            textField.layer.borderColor = UIColor.systemRed.cgColor
            label.textColor = .systemRed
            shakeIt(textField)
        } else {
            textField.layer.borderColor = UIColor.systemGreen.cgColor
            label.textColor = .systemGreen
        }
    }
    
    @IBAction func changeTextField(_ textField: UITextField) {
        let identifier = textField.accessibilityIdentifier
        if identifier == "barcode" {
            extendedChangeTextField(barcodeLbl, textField)
        } else if identifier == "name" {
            extendedChangeTextField(nameLbl, textField)
        } else if identifier == "description"{
            extendedChangeTextField(descriptionLbl, textField)
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
                dollarSymLbl.isHidden = true
                shakeIt(textField)
            } else {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                priceLbl.textColor = .systemGreen
                dollarSymLbl.isHidden = false
            }
        }
        checkForm()
    }
    
    
    @IBAction func scanBarcodeBtn(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            performSegue(withIdentifier: "barcodeScannerSegue", sender: nil)
        } else {
            self.showAlert(withTitle: "inventoTrack",message: "There seems to be a problem with the camera on your device.")
        }
    }
    
    
    func checkForm() {
        if !barcodeTF.text!.isEmpty && !nameTF.text!.isEmpty &&  !descriptionTF.text!.isEmpty &&  !qtyTF.text!.isEmpty &&  !priceTF.text!.isEmpty  {
            addBtn.isEnabled = true
        } else {
            addBtn.isEnabled = false
        }
    }
    
    func didFindScannedText(text: String) {
        enterTextField(barcodeTF)
        barcodeTF.text = text
        barcodeTF.becomeFirstResponder()
        checkForm()
    }
}

extension AddProductViewController {
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
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
}

