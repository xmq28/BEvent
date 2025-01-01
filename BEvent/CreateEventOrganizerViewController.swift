import UIKit
import FirebaseFirestore

class CreateEventOrganizerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    @IBOutlet weak var usernameTextField: UITextField!
  
    @IBOutlet weak var emailTextField: UITextField!
  
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    

    @IBOutlet weak var permissionsPicker: UIPickerView!
    let db = Firestore.firestore()
    let permissions = ["Basic Organizer", "Lead Organizer"]
    var selectedPermission: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        permissionsPicker.delegate = self
        permissionsPicker.dataSource = self
    }

    // MARK: - UIPickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return permissions.count
    }

    // MARK: - UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return permissions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPermission = permissions[row]
    }

  
    @IBAction func submitButton(_ sender: UIButton) {
    
    guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let permission = selectedPermission else {
            showAlert(title: "Error", message: "Please fill in all fields and select a permission.")
            return
        }

        let organizerData: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "permissions": permission
        ]

        db.collection("organizers").addDocument(data: organizerData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to create organizer: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "A new organizer has been created!")
                self.clearFields()
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    private func clearFields() {
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        permissionsPicker.selectRow(0, inComponent: 0, animated: true)
        selectedPermission = nil
    }
}
