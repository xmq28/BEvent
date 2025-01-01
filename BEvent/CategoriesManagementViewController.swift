import UIKit
import FirebaseFirestore

class CategoriesManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
 
    

    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var editCategoryButton: UIButton!
    @IBOutlet weak var deleteCategoryButton: UIButton!
    
    // MARK: - Variables
    var db = Firestore.firestore()
    var categories: [String] = [] // Array to store category names
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        
        // Register cell
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        // Fetch categories from Firestore
        fetchCategories()
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() {
        db.collection("categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                self.categories = snapshot.documents.map { $0.documentID }
                DispatchQueue.main.async {
                    self.categoriesTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    
    // MARK: - Button Actions
    @IBAction func addCategory(_ sender: UIButton) {
        navigateToSubpage(identifier: "AddCategoryViewController")
    }
    
    @IBAction func editCategory(_ sender: UIButton) {
        navigateToSubpage(identifier: "EditCategoryViewController")
    }
    
    @IBAction func deleteCategory(_ sender: UIButton) {
        navigateToSubpage(identifier: "DeleteCategoryViewController")
    }
    
    // MARK: - Navigation Helper
    func navigateToSubpage(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
