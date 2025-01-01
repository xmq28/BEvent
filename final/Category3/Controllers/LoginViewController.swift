//
//  LoginViewController.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.

import UIKit
import FirebaseAuth
import Foundation
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginEmailTextField.delegate = self
        LoginPasswordTextField.delegate = self
    }
    
    // For db
    let ref = Database.database().reference()
    
    // Creating outlets for the fields
    @IBOutlet weak var LoginEmailTextField: UITextField!
    @IBOutlet weak var LoginPasswordTextField: UITextField!

    @IBAction func LoginButton(_ sender: UIButton) {
        validateFields()
    }

    // Show alert message for user
    func showInvalidEmailAlert() {
        let alertController = UIAlertController(title: "Invalid Email Format",
                                                message: "Please enter a valid email address.",
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func validateFields() {
        // Validations for input fields
        if LoginEmailTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "Empty Field", message: "Please Enter Your Email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }

        if LoginPasswordTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "Empty Field", message: "Please Enter Your Password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }

        guard let email = LoginEmailTextField.text else { return }
        
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            showInvalidEmailAlert()
            return
        }

        // Start login process after validation
        login()
    }

    func login() {
        guard let email = LoginEmailTextField.text?.lowercased(), let password = LoginPasswordTextField.text else {
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.showInvalidCredentialsAlert()
                print("Authentication failed: \(error.localizedDescription)")
                return
            }

            // Proceed to check user info
            self.checkUserInfo()
        }
    }

    func showInvalidCredentialsAlert() {
        let alertController = UIAlertController(title: "Invalid Credentials",
                                                message: "The email or password you entered were invalid. Please try again.",
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    // Double check that the user logged in and has information
    func checkUserInfo() {
        if Auth.auth().currentUser != nil {
            guard let email = Auth.auth().currentUser?.email else {
                print("Email is null")
                return
            }
            
            // Save the user's UID in UserDefaults
            UserDefaults.standard.set(Auth.auth().currentUser!.uid, forKey: "user_uid_key")

            let user = AppData.getUserFromEmail(email: LoginEmailTextField.text!)
            AppData.loggedInUser = user
            
            let viewControllerIdentifier: String
            
            // Determine the view controller to display based on the user's email
            if email.contains("@bevent.admin") {
                viewControllerIdentifier = "AdminTabBarController"
            } else if email.contains("@bevent.organizer") {
                viewControllerIdentifier = "EventTabBarController"
            } else {
                viewControllerIdentifier = "AttendeeTabBarController"
            }
            
            // Instantiate the corresponding view controller
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
            
            // Set the root view controller
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
        }
    }

    // Inherited from UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == LoginEmailTextField {
            LoginPasswordTextField.becomeFirstResponder()
        } else {
            validateFields()
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
