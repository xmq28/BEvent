import UIKit
import FirebaseFirestore

class EditCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var categoryPicker: UIPickerView!
 
    @IBOutlet weak var editCategory: UIButton!
    
    @IBOutlet weak var newCategoryNameTextField: UITextField!
    var db = Firestore.firestore()
    var categories: [String] = []
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        fetchCategories()
    }
    
  
    // Fetch categories from Firestore
    func fetchCategories() {
        db.collection("categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error)")
            } else if let snapshot = snapshot {
                self.categories = snapshot.documents.map { $0.documentID }
                self.categoryPicker.reloadAllComponents()
            }
        }
    }
    
    // MARK: - PickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
    

    @IBAction func editCategory(_ sender: UIButton) {
    guard let selectedCategory = selectedCategory,
              let newCategoryName = newCategoryNameTextField.text, !newCategoryName.isEmpty else {
            showAlert(title: "Error", message: "Please select a category and enter a new name.")
            return
        }
        
        // Update the category name in Firestore
        db.collection("categories").document(selectedCategory).delete() { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to update category: \(error.localizedDescription)")
            } else {
                self.db.collection("categories").document(newCategoryName).setData(["created_at": Date()]) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: "Failed to add updated category: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Success", message: "Edit to \"\(newCategoryName)\" has been made!")
                        self.newCategoryNameTextField.text = ""
                        self.fetchCategories() // Reload categories
                    }
                }
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
