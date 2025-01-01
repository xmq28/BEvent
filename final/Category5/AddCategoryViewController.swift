import UIKit
import FirebaseFirestore

class AddCategoryViewController: UIViewController {
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var addCategory: UIButton!
    
    var db = Firestore.firestore()
   

    @IBAction func addCategory(_ sender: UIButton) {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else {
            showAlert(title: "Error", message: "Category name cannot be empty.")
            return
        }
        
        db.collection("categories").document(categoryName).setData(["created_at": Date()]) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to add category: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "A new category \"\(categoryName)\" has been created!")
                self.categoryNameTextField.text = "" // Clear the text field
            }
        }
    }

    
    // Show Alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
