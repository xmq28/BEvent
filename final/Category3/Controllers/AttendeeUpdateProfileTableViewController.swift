import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase // Import FirebaseDatabase

class AttendeeUpdateProfileTableViewController: UITableViewController, UITextFieldDelegate {
    
    let ref = Database.database().reference() // Initialize Realtime Database
    var existingMobile: String?

    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate for text fields
        fnameField.delegate = self
        lnameField.delegate = self
        mobileField.delegate = self
        
        // Load existing user data
        loadUserData()
    }
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = ref.child("users").child(user.uid) // Use uid for Realtime Database
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let data = snapshot.value as? [String: Any]
                self.fnameField.text = data?["firstName"] as? String
                self.lnameField.text = data?["lastName"] as? String
                self.mobileField.text = data?["mobileNum"] as? String
                
                // Store existing mobile
                self.existingMobile = data?["mobileNum"] as? String
            } else {
                print("User document does not exist.")
            }
        }
    }

    @IBAction func updateBtnTapped(_ sender: Any) {
        validateFields()
    }

    func validateFields() {
        // Validation for First Name
        if fnameField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your First Name")
            return
        }

        // Validation for Last Name
        if lnameField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Last Name")
            return
        }

        // Validation for Mobile
        if mobileField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Mobile Number")
            return
        }

        guard let mobile = mobileField.text else { return }
        let mobileRegex = "^[0-9]{8}$"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        if !mobilePredicate.evaluate(with: mobile) {
            showAlert(message: "Please enter a valid mobile number consisting of 8 digits.")
            return
        }

        // Check uniqueness of mobile only if it is different from existing value
        if mobile != existingMobile {
            checkUniqueness(mobile: mobile)
        } else {
            // If mobile is the same, just update the user data directly
            updateUserData(mobile: mobile)
        }
    }

    func showAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // Navigate back to the Settings screen
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        }

    func checkUniqueness(mobile: String) {
        let usersRef = ref.child("users") // Reference to your users in Realtime Database

        // Check for existing mobile number
        usersRef.queryOrdered(byChild: "mobileNum").queryEqual(toValue: mobile).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.showAlert(message: "This mobile number is already registered.")
                return
            }

            // Update user data if mobile is unique
            self.updateUserData(mobile: mobile)
        }
    }

    func updateUserData(mobile: String) {
        guard let user = Auth.auth().currentUser else { return }
        let userData: [String: Any] = [
            "firstName": fnameField.text!,
            "lastName": lnameField.text!,
            "mobileNum": mobile
        ]

        ref.child("users").child(user.uid).updateChildValues(userData) { error, _ in
            if let error = error {
                self.showAlert(message: "Error updating user data: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Profile updated successfully!")
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fnameField {
            lnameField.becomeFirstResponder()
        } else if textField == lnameField {
            mobileField.becomeFirstResponder()
        } else {
            mobileField.resignFirstResponder()
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
