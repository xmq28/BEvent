import UIKit
import FirebaseFirestore

class ManagingEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventsTableView: UITableView!
    var db = Firestore.firestore()
    var events: [[String: Any]] = [] // Data from Firebase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the TableView
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        fetchEventsFromFirestore()
    }
    
    // Load data from Firebase
    func fetchEventsFromFirestore() {
        db.collection("events").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                // Map the documents to include event names as document IDs
                self.events = snapshot.documents.map { document in
                    var eventData = document.data()
                    eventData["name"] = document.documentID // Set the document ID as the name
                    return eventData
                }
                DispatchQueue.main.async {
                    self.eventsTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let event = events[indexPath.row]
        cell.textLabel?.text = event["name"] as? String ?? "Event Name" // Display event name
        return cell
    }
    
    // Navigate to Alter Status
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let alterStatusVC = storyboard.instantiateViewController(withIdentifier: "AlterStatusViewController") as? AlterStatusViewController {
            alterStatusVC.selectedEvent = events[indexPath.row] // Pass the selected event
            navigationController?.pushViewController(alterStatusVC, animated: true)
        }
    }
}
