//
//  BackupViewController.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-13.
//

import UIKit
import UniformTypeIdentifiers
import GoogleSignIn

class BackupViewController: UIViewController, UIDocumentPickerDelegate {
    
    var loadingView: UIView?
    
    @IBOutlet weak var uploadGoogleBtn: UIButton!
    @IBOutlet weak var restoreGoogleBtn: UIButton!
    @IBOutlet weak var googleDriveImg: UIImageView!
    @IBOutlet weak var offlineImg: UIImageView!
    let viewModel = BackupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        viewModel.didGoogleSignedIn { signedIn in
            if signedIn {
                self.uploadGoogleBtn.isEnabled = true
                self.restoreGoogleBtn.isEnabled = true
            } else {
                self.uploadGoogleBtn.isEnabled = false
                self.restoreGoogleBtn.isEnabled = false
            }
        }
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            // Update the properties you want to animate
            self.googleDriveImg.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.offlineImg.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    @IBAction func saveBackup(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyyy-HHmmss"
        let currentDate = formatter.string(from: Date())
        if let data = CoreDataManager.shared.fetchData() {
            if let json = CoreDataManager.shared.convertToJSON(data: data) {
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    return
                }
                
                let fileURL = documentsDirectory.appendingPathComponent("inventoTrack-\(currentDate).json")
                
                do {
                    try json.write(to: fileURL, options: .atomic)
                    let exportJSON = UIActivityViewController(activityItems: [fileURL as Any], applicationActivities: nil)
                    exportJSON.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, error) in
                        if completed {
                            self?.showAlert(withTitle: "inventoTrack", message: "Data Successfully Saved!")
                        }
                        // Dismiss the view controller when sharing/exporting is completed or canceled
                        self?.deleteTempFile(url: fileURL)
                    }
                    present(exportJSON, animated: true, completion: nil)
                } catch let error {
                    print("Failed to save data: \(error)")
                }
            }
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
    
    @IBAction func restoreBackup(_ sender: Any) {
        fetchJSONFileFromDocumentPicker()
    }
    
    func fetchJSONFileFromDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow selecting multiple files
        
        // Present the document picker to the user
        present(documentPicker, animated: true, completion: nil)
    }
    
    // Delegate method to handle the selected document
    @objc func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let fileURL = urls.first else {
            print("No file selected")
            return
        }
        guard fileURL.startAccessingSecurityScopedResource() else {
            return
        }
        // Fetch data from the selected file
        if let jsonData = viewModel.fetchDataFromLocalFile(fileURL: fileURL) {
            
            let alert = UIAlertController(title: "inventoTrack", message: "Are you sure you want to restore? Current data will be deleted.", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                CoreDataManager.shared.deleteAllProduct()
                if self.viewModel.processJSONData(jsonData) {
                    
                }
            })
            alert.addAction(okayAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func uploadToGoogleDrive(_ sender: Any) {
        GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            let accessToken = user.accessToken.tokenString
            
            self.searchFileInGoogleDrive(accessToken: accessToken, fileName: "inventoTrack-backup-data.json"){ [weak self] fileId in
                if let fileId = fileId {
                    
                    if let data = CoreDataManager.shared.fetchData() {
                        if let json = CoreDataManager.shared.convertToJSON(data: data) {
                            self?.showFileExistsAlert(accessToken: accessToken, fileId: fileId, jsonData: json)
                        }
                    }
                } else {
                    if let data = CoreDataManager.shared.fetchData() {
                        if let json = CoreDataManager.shared.convertToJSON(data: data) {
                            self?.createFileInGoogleDrive(accessToken: accessToken, jsonData: json, fileName: "inventoTrack-backup-data.json")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func restoreFromGoogleDrive(_ sender: Any) {
        
        let alert = UIAlertController(title: "inventoTrack", message: "Are you sure you want to restore? Current data will be deleted.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
//            GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
//                guard error == nil else { return }
//                guard let user = user else { return }
//
//                let accessToken = user.accessToken.tokenString
//
//                self.fetchJSONFromGoogleDriveAndRestoreToCoreData(accessToken: accessToken)
//            }
            self.viewModel.getAccessToken { accessToken in
                self.fetchJSONFromGoogleDriveAndRestoreToCoreData(accessToken: accessToken)
            }
        })
        alert.addAction(okayAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func createFileInGoogleDrive(accessToken: String, jsonData: Data, fileName: String) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType = "multipart/related; boundary=\(boundary)"
        
        guard let uploadURL = URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart") else {
            print("Invalid upload URL")
            return
        }
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = self.createRequestBody(jsonData: jsonData, fileName: fileName, boundary: boundary)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Upload failed. Error: \(error.localizedDescription)")
                return
            }
            
            // Handle the upload response if needed
            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let fileId = responseJSON["id"] as? String,
                   let fileName = responseJSON["name"] as? String {
                    // Show a notification or alert with the file ID or name
                    DispatchQueue.main.async {
                        self.showAlert(withTitle: "inventoTrack", message: "Successfully uploaded \(fileName)!\n\nFileID: \(fileId)")
                    }
                } else {
                    print("Invalid response data")
                }
            }
        }
        task.resume()
    }
    
    func updateFileInGoogleDrive(accessToken: String, fileId: String, jsonData: Data){
        let updateURLString = "https://www.googleapis.com/upload/drive/v3/files/\(fileId)?uploadType=media"
        guard let updateURL = URL(string: updateURLString) else {
            print("Invalid update URL")
            return
        }
        
        var request = URLRequest(url: updateURL)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Update failed. Error: \(error.localizedDescription)")
                return
            }
            
            // Handle the update response if needed
            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let fileId = responseJSON["id"] as? String,
                   let fileName = responseJSON["name"] as? String {
                    // Show a notification or alert with the file ID or name
                    DispatchQueue.main.async {
                        self.showAlert(withTitle: "inventoTrack", message: "Successfully updated \(fileName)!\n\nFileID: \(fileId)")
                    }
                } else {
                    print("Invalid response data")
                }
            }
        }
        
        task.resume()
    }
    
    func searchFileInGoogleDrive(accessToken: String, fileName: String, completion: @escaping (String?) -> Void) {
        
        let query = "name = '\(fileName)'"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURLString = "https://www.googleapis.com/drive/v3/files?q=\(encodedQuery ?? "")&fields=files(id)"
        
        guard let searchURL = URL(string: searchURLString) else {
            print("Invalid search URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("File search failed. Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let files = responseJSON["files"] as? [[String: Any]],
                   let fileId = files.first?["id"] as? String {
                    // File found
                    completion(fileId)
                    return
                }
            }
            
            // File not found
            completion(nil)
        }
        
        task.resume()
    }
    
    func createRequestBody(jsonData: Data, fileName: String, boundary: String) -> Data {
        var body = Data()
        
        // Add metadata part
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Type: application/json; charset=UTF-8\r\n".utf8))
        body.append(Data("\r\n".utf8))
        body.append(Data("{\"name\": \"\(fileName)\"}\r\n".utf8))
        
        // Add media part
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Type: application/json\r\n".utf8))
        body.append(Data("\r\n".utf8))
        body.append(jsonData)
        body.append(Data("\r\n".utf8))
        
        // Add final boundary
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
    
    func fetchJSONFromGoogleDriveAndRestoreToCoreData(accessToken: String) {
        searchFileInGoogleDrive(accessToken: accessToken, fileName: "inventoTrack-backup-data.json") { [weak self] fileId in
            guard let self = self else { return }
            
            guard let fileId = fileId else {
                self.showAlert(withTitle: "inventoTrack", message: "No backup data found!")
                return
            }
            self.downloadFileFromGoogleDrive(accessToken: accessToken, fileId: fileId) { [weak self] fileData in
                guard let self = self else { return }
                
                guard let fileData = fileData else {
                    print("Error downloading file from Google Drive")
                    return
                }
                CoreDataManager.shared.deleteAllProduct()
                if viewModel.processJSONData(fileData) {
                    showAlert(withTitle: "inventoTrack", message: "Data successfully restored!")
                }
                    // Store the data in Core Data
                
            }
        }
    }
    
    func downloadFileFromGoogleDrive(accessToken: String, fileId: String, completion: @escaping (Data?) -> Void) {
        let downloadURLString = "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media"
        guard let downloadURL = URL(string: downloadURLString) else {
            print("Invalid download URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: downloadURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Download failed. Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    func showLoadingView() {
        // Create a loading view with an activity indicator
        let loaderView = UIView(frame: view.bounds)
        loaderView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loaderView.center
        activityIndicator.startAnimating()
        
        // Add the activity indicator to the loading view
        loaderView.addSubview(activityIndicator)
        
        // Add the loading view as a subview
        view.addSubview(loaderView)
        
        // Keep a reference to the loading view
        loadingView = loaderView
    }
    
    func hideLoadingView() {
        // Remove the loading view from the superview
        loadingView?.removeFromSuperview()
        
        // Reset the reference to the loading view
        loadingView = nil
    }
    
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    private func showFileExistsAlert(accessToken: String, fileId: String, jsonData: Data){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "inventoTrack", message: "File Already Exists!\n\nOverwrite the file?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { [weak self] _ in
                self?.updateFileInGoogleDrive(accessToken: accessToken, fileId: fileId, jsonData: jsonData)
            }
            alertController.addAction(overwriteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
}
