import UIKit
import FirebaseFirestore

class EditOrganizerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var usernameTextField: UITextField!
  
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var permissionsPicker: UIPickerView!

    @IBOutlet weak var saveButton: UIButton!
    
    var db = Firestore.firestore()
    var permissions = ["Basic", "Lead", "Admin"] // Example permission options
    var selectedPermission: String?
    var organizerDetails: [String: Any]? // Details of the organizer passed from the previous screen

    override func viewDidLoad() {
        super.viewDidLoad()
        permissionsPicker.delegate = self
        permissionsPicker.dataSource = self

        // Load existing organizer details into the UI
        if let organizer = organizerDetails {
            usernameTextField.text = organizer["username"] as? String
            emailTextField.text = organizer["email"] as? String
            if let currentPermission = organizer["permission"] as? String {
                if let index = permissions.firstIndex(of: currentPermission) {
                    permissionsPicker.selectRow(index, inComponent: 0, animated: false)
                    selectedPermission = currentPermission
                }
            }
        }
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

    @IBAction func saveChanges(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let permission = selectedPermission,
              let organizerId = organizerDetails?["id"] as? String else {
            return
        }

        // Save updated organizer details in Firestore
        db.collection("organizers").document(organizerId).updateData([
            "username": username,
            "email": email,
            "permission": permission
        ]) { error in
            if let error = error {
                print("Error updating organizer details: \(error)")
            } else {
                // Show alert after saving
                let alert = UIAlertController(
                    title: "Success",
                    message: "Edit to \"\(username)\" details has been made!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
