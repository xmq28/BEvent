//
//  Alerts.swift
//  final
//
//  Created by Sara Khalaf on 05/12/2024.
//

import Foundation
import UIKit
import FirebaseAuth

extension UIViewController {
    func confirmation(title: String, message: String, confirmHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .default) { action in
            confirmHandler()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func logoutAlert() {
        confirmation(title: "Confirm Log Out", message: "Are you sure you would like to log out?", confirmHandler: {
            // Sign out from Firebase
            do {
                try Auth.auth().signOut()
                
                // Remove UID from UserDefaults
                UserDefaults.standard.removeObject(forKey: "user_uid_key")
                
                // Redirect to Login View
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginT")
                self.view.window?.rootViewController = viewController
                self.view.window?.makeKeyAndVisible()
            } catch {
                self.errorAlert(title: "Error", message: "There was a problem signing out.")
            }
        })
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}
