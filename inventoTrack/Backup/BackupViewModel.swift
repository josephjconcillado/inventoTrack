//
//  BackupViewModel.swift
//  inventoTrack
//
//  Created by jconcillado on 2023-07-26.
//

import Foundation
import UIKit
import GoogleSignIn
import UniformTypeIdentifiers

class BackupViewModel {
    
    var showAlert: ((String) -> Void)?
    var onOk: (() -> Void)?
    var onCancel: (() -> Void)?
    var manager = CoreDataManager.shared
    
    func didGoogleSignedIn(completion: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                completion(false)
            } else {
                // Show the app's signed-in state.
                completion(true)
            }
        }
    }
    
    func getAccessToken(completion: @escaping (String) -> Void) {
        GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            
            let accessToken = user.accessToken.tokenString
            completion(accessToken)
        }
    }
    
    func fetchDataFromLocalFile(fileURL: URL) -> Data? {
        do {
            let data = try Data(contentsOf: fileURL)
            
            // Make sure you release the security-scoped resource when you finish.
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            return data
        } catch let error {
            print("Failed to fetch data from local file: \(error)")
            return nil
        }
    }
    
    func processJSONData(_ jsonData: Data) -> Bool {
        // Process the fetched JSON data here
        if manager.convertJSONToCoreData(jsonData: jsonData) {
            return true
        } else {
            return false
        }
    }
    
}
