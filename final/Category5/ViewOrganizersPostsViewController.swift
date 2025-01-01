import UIKit
import FirebaseFirestore

class ViewOrganizersPostsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var organizerPicker: UIPickerView!
    @IBOutlet weak var eventsTableView: UITableView!
    
    let db = Firestore.firestore() // Firestore reference
    var uniqueOrganizerUsernames: [String] = [] // List of unique organizer usernames
    var selectedOrganizer: String?
    var events: [[String: Any]] = [] // List of events for the selected organizer

    override func viewDidLoad() {
        super.viewDidLoad()
        organizerPicker.delegate = self
        organizerPicker.dataSource = self
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        fetchUniqueOrganizers() // Fetch unique usernames of organizers from the events collection
    }

    func fetchUniqueOrganizers() {
        db.collection("events").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return } // Safely unwrap self to avoid retain cycles
            
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            // Create a set to store unique usernames
            var uniqueOrganizersSet = Set<String>()
            
            // Gather unique usernames from the fetched event documents
            snapshot?.documents.forEach { document in
                if let username = document.data()["username"] as? String {
                    uniqueOrganizersSet.insert(username)
                }
            }
            
            self.uniqueOrganizerUsernames = Array(uniqueOrganizersSet) // Convert Set back to Array
            self.organizerPicker.reloadAllComponents() // Reload the picker view with unique organizers
            
            // Automatically select the first organizer if available and fetch their events
            if let firstOrganizer = self.uniqueOrganizerUsernames.first {
                self.selectedOrganizer = firstOrganizer
                self.fetchEvents(for: firstOrganizer) // Fetch events for the first selected organizer
            }
        }
    }

    func fetchEvents(for organizer: String) {
        db.collection("events").whereField("username", isEqualTo: organizer).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return } // Safely unwrap self
            
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            // Store the fetched events in the events array
            self.events = snapshot?.documents.map { document in
                var event = document.data()
                event["name"] = document.documentID // Assign the event ID as the name
                event["username"] = event["username"] // Ensure the username is included
                return event
            } ?? []
            self.eventsTableView.reloadData() // Reload the table view with event data
        }
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single component for the Picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return uniqueOrganizerUsernames.count // Number of rows based on the count of unique usernames
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return uniqueOrganizerUsernames[row] // Display each username in the picker
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOrganizer = uniqueOrganizerUsernames[row] // Update selected organizer
        fetchEvents(for: selectedOrganizer!) // Fetch events for the newly selected organizer
    }

    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count // Count of the fetched events
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        cell.textLabel?.text = events[indexPath.row]["name"] as? String ?? "No Name" // Display event name
        cell.detailTextLabel?.text = events[indexPath.row]["username"] as? String ?? "No Username" // Display associated username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row] // Get the selected event
        performSegue(withIdentifier: "toEventDetails", sender: event) // Perform segue to event details
    }

    // Prepare the event data to pass to the details view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetails" {
            let destinationVC = segue.destination as! EventDetailsViewController
            destinationVC.event = sender as? [String: Any] // Pass the selected event data to the destination view controller
        }
    }
}
