//
//  ChangePasswordTableViewController.swift
//  final
//
//  Created by Sara Khalaf on 05/12/2024.
//

import UIKit
import FirebaseAuth

class ChangePasswordTableViewController: UITableViewController {
    
    // Variables
    var loggedInUser: User? = AppData.loggedInUser
    var attendeeLog: Attendee?
    
    // Declaring elements
    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    // Function to update the password
    @IBAction func updatePasswordButtonTapped(_ sender: UIButton) {
        guard let oldPassword = oldPassField.text, !oldPassword.isEmpty,
              let newPassword = newPassField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPassField.text, !confirmPassword.isEmpty else {
            showAlert("All fields are required.")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert("New password and confirmation do not match.")
            return
        }
        
        // Re-authenticate user
        guard let user = Auth.auth().currentUser else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)
        
        user.reauthenticate(with: credential) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert("Re-authentication failed: \(error.localizedDescription)")
                return
            }
            
            // Update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert("Password update failed: \(error.localizedDescription)")
                } else {
                    self.showAlert("Password updated successfully.")
                    self.clearFields()
                }
            }
        }
    }
    
    // Function to show alerts
        private func showAlert(_ message: String) {
            let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // Navigate back to the Settings screen
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    // Function to clear text fields
    private func clearFields() {
        oldPassField.text = ""
        newPassField.text = ""
        confirmPassField.text = ""
    }
}
