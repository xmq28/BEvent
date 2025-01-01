import UIKit
import FirebaseFirestore

class ManagingOrganizersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var organizersTableView: UITableView!
    
    var db = Firestore.firestore()
    var organizers: [[String: Any]] = [] // Array to hold organizers data

    override func viewDidLoad() {
        super.viewDidLoad()
        organizersTableView.delegate = self
        organizersTableView.dataSource = self
        organizersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrganizerCell")

        fetchOrganizers() // Fetch data dynamically
    }

    func fetchOrganizers() {
        db.collection("organizers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching organizers: \(error.localizedDescription)")
                return
            }

            self.organizers = snapshot?.documents.compactMap { doc in
                var data = doc.data()
                data["id"] = doc.documentID // Add document ID
                return data
            } ?? []

            DispatchQueue.main.async {
                self.organizersTableView.reloadData() // Reload table with the fetched data
            }
        }
    }

    // MARK: - TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerCell", for: indexPath)

        let organizer = organizers[indexPath.row]
        if let username = organizer["username"] as? String,
           let email = organizer["email"] as? String,
           let permissions = organizer["permissions"] as? String,
           let eventsPosted = organizer["numberOfEventsPosted"] as? Int {
            cell.textLabel?.text = "\(username) | \(email) | \(permissions) | \(eventsPosted) events"
        }

        return cell
    }

    // MARK: - Row Actions for Edit and Delete
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let organizer = organizers[indexPath.row]
        let alert = UIAlertController(title: "Actions", message: "Choose an action for this organizer", preferredStyle: .actionSheet)

        // Edit Action
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            self.navigateToEditOrganizer(organizer: organizer)
        }))

        // Delete Action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteOrganizer(organizer: organizer, at: indexPath)
        }))

        // Cancel Action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    //Edit organizers
    func navigateToEditOrganizer(organizer: [String: Any]) {
        // Load storyboard and view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editOrganizerVC = storyboard.instantiateViewController(withIdentifier: "EditOrganizerViewController") as? EditOrganizerViewController {
            // Pass organizer details
            editOrganizerVC.organizerDetails = organizer
            
            // Push to the navigation stack
            if let navController = navigationController {
                navController.pushViewController(editOrganizerVC, animated: true)
            } else {
                print("Error: Navigation controller not found.")
            }
        } else {
            print("Error: EditOrganizerViewController could not be instantiated.")
        }
    }


    // MARK: - Delete Organizer
    func deleteOrganizer(organizer: [String: Any], at indexPath: IndexPath) {
        guard let organizerId = organizer["id"] as? String else {
            print("Error: Organizer ID not found.")
            return
        }

        db.collection("organizers").document(organizerId).delete { error in
            if let error = error {
                print("Error deleting organizer: \(error.localizedDescription)")
            } else {
                self.organizers.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.organizersTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                print("Organizer deleted successfully.")
            }
        }
    }
}

