import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    
    var categories: [String] = []
    var selectedCategories: Set<String> = [] // Track selected categories

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategories()
        fetchSelectedCategories() // Fetch selected categories
    }
    
    // Fetch categories from Firestore
    func fetchCategories() {
        let db = Firestore.firestore()
        db.collection("categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error)")
            } else if let snapshot = snapshot {
                self.categories = snapshot.documents.map { $0.documentID }
                self.tableView.reloadData() // Reload table view with categories
            }
        }
    }

    // Fetch selected categories from Firebase
    func fetchSelectedCategories() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let userRef = Database.database().reference().child("users").child(uid)
        userRef.child("preferences").observeSingleEvent(of: .value) { snapshot in
            if let preferencesArray = snapshot.value as? [String] {
                self.selectedCategories = Set(preferencesArray) // Update selected categories
                self.tableView.reloadData() // Reload table view to reflect changes
            } else {
                print("No preferences found.")
            }
        }
    }

    @IBAction func saveSelectedCategories(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let preferencesArray = Array(selectedCategories)
        let userRef = Database.database().reference().child("users").child(uid)

        userRef.updateChildValues(["preferences": preferencesArray]) { error, _ in
            if let error = error {
                print("Error updating preferences: \(error.localizedDescription)")
                self.showAlert("Error updating preferences: \(error.localizedDescription)")
            } else {
                print("Preferences updated successfully: \(preferencesArray)")
                self.showAlert("Preferences updated successfully: \(preferencesArray.joined(separator: ", "))")
            }
        }
    }

    // Function to show alerts
    private func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate back to the settings screen
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count // Number of categories
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        
        let category = categories[indexPath.row]
        cell.titleLabel?.text = category
        
        // Update checkmark button state based on selected categories
        cell.isCompleteButton.isSelected = selectedCategories.contains(category)
        cell.delegate = self
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false // Disable editing
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let category = categories[indexPath.row]
            if selectedCategories.contains(category) {
                selectedCategories.remove(category) // Deselect the category
            } else {
                selectedCategories.insert(category) // Select the category
            }
            tableView.reloadRows(at: [indexPath], with: .automatic) // Update UI
        }
    }
}
