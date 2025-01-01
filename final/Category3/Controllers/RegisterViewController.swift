import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class RegisterForm1ViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore() // Initialize Firestore database
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate for text fields
        FirstNameTextField.delegate = self
        LastNameTextField.delegate = self
        MobileTextField.delegate = self
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
    }
    
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var MobileTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var DatePicker: UIDatePicker!

    func showInvalidEmailAlert() {
        let alertController = UIAlertController(title: "Invalid Email Format",
                                                message: "Please enter a valid email address.",
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
    @IBAction func registerBtnTapped(_ sender: Any) {
        validateFields()
    }
    func validateFields() {
        // Validation for FirstName empty field
        if FirstNameTextField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your First Name")
            return
        }

        // Validation for LastName field
        if LastNameTextField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Last Name")
            return
        }

        // Validation for Mobile field
        if MobileTextField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Mobile Number")
            return
        }

        guard let mobile = MobileTextField.text else { return }
        let mobileRegex = "^[0-9]{8}$"
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@", mobileRegex)
        if !mobilePredicate.evaluate(with: mobile) {
            showInvalidMobileAlert()
            return
        }

        // Validation for Email field
        if EmailTextField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Email")
            return
        }

        guard let email = EmailTextField.text?.lowercased() else { return }
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            showInvalidEmailAlert()
            return
        }
        
        // Check if email contains '@bevent'
           if email.contains("@bevent") {
                showAlert(message: "Registration is not allowed with @bevent emails Please use a different email address.")
                return
            }

        // Validation for Password field
        if PasswordTextField.text?.isEmpty == true {
            showAlert(message: "Please Enter Your Password")
            return
        }

        let password = PasswordTextField.text ?? ""
        let passwordLength = password.count
        let minimumPasswordLength = 8
        if passwordLength < minimumPasswordLength {
            showAlert(message: "Password should be at least \(minimumPasswordLength) characters long for more security.")
            return
        }

        // Check if the user is older than 15 years
        let dateComponents = Calendar.current.dateComponents([.year], from: Date())
        let currentYear = dateComponents.year!
        let selectedDateComponents = Calendar.current.dateComponents([.year], from: DatePicker.date)
        let selectedYear = selectedDateComponents.year!

        if (currentYear - selectedYear) < 15 {
            showAlert(message: "You must be at least 15 years old to register.")
            return
        }

        // Check email and mobile uniqueness in Firestore
        checkUniqueness(email: email, mobile: mobile)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    func showInvalidMobileAlert() {
        showAlert(message: "Please enter a valid mobile number consisting of 8 digits.")
    }

    func checkUniqueness(email: String, mobile: String) {
            let usersRef = ref.child("users") // Reference to your users in Realtime Database

            // Check for existing email
            usersRef.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    self.showAlert(message: "This email is already registered.")
                    return
                }

                // Check for existing mobile number
                usersRef.queryOrdered(byChild: "mobileNum").queryEqual(toValue: mobile).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        self.showAlert(message: "This mobile number is already registered.")
                        return
                    }

                    // Call Register function if both checks are valid
                    self.register(email: email, password: self.PasswordTextField.text ?? "")
                }
            }
        }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [self] (authResult, error) in
            guard let _ = authResult?.user, error == nil else {
                print("Error \(String(describing: error?.localizedDescription))")
                return
            }

            // Register the user in Realtime Database
            let userData: [String: Any] = [
                "email": EmailTextField.text!,
                "firstName": FirstNameTextField.text!,
                "lastName": LastNameTextField.text!,
                "mobileNum": MobileTextField.text!,
                "gender": genderSegmentedControl.selectedSegmentIndex == 0 ? "Male" : "Female",
                "dateOfBirth": DatePicker.date.timeIntervalSince1970, // Store as timestamp
                "role": "attendee", // Add role
                "preferences": [] // Initialize preferences as an empty array
            ]

            // Use the uid as a unique identifier
            if let uid = Auth.auth().currentUser?.uid {
                self.ref.child("users").child(uid).setValue(userData) { error, _ in
                    if let error = error {
                        print("Error storing user data: \(error.localizedDescription)")
                    } else {
                        self.backToLogin()
                    }
                }
            }
        }
    }

    func backToLogin() {
        let alertController = UIAlertController(title: "Successfully Registered!",
                                                message: "Please proceed to the login page to complete the signing-in process.",
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "login")
            self?.view.window?.rootViewController = viewController
            self?.view.window?.makeKeyAndVisible()
        }

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == FirstNameTextField {
            LastNameTextField.becomeFirstResponder()
        } else if textField == LastNameTextField {
            MobileTextField.becomeFirstResponder()
        } else if textField == MobileTextField {
            EmailTextField.becomeFirstResponder()
        } else if textField == EmailTextField {
            PasswordTextField.becomeFirstResponder()
        } else {
            validateFields()
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
