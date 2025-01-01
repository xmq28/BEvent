import UIKit
import FirebaseFirestore

class manageEvent: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // IBOutlet for the UI elements
    @IBOutlet weak var handleEventDeletion: UISegmentedControl!
    @IBOutlet weak var eventTitle: UIPickerView!
    @IBOutlet weak var eventStatus: UIPickerView!
    
    // Firestore reference
    var db: Firestore!
    
    // Array to hold event titles
    var eventTitles: [String] = []
    
    // Store event status options
    let eventStatuses = ["active", "inactive", "postponed", "canceled"]
    
    var selectedEventId: String?
    var selectedStatus: String = "active" // Default status
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Firestore
        db = Firestore.firestore()

        // Set picker view delegates
        eventTitle.delegate = self
        eventTitle.dataSource = self
        eventStatus.delegate = self
        eventStatus.dataSource = self

        // Fetch event titles from Firestore (from 'createEvent' collection)
        fetchEventTitles()
    }

    // Fetch event titles from Firestore (from 'createEvent' collection)
    func fetchEventTitles() {
        db.collection("createEvent").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot data.")
                return
            }

            // Parse the event titles into the array
            self.eventTitles = snapshot.documents.compactMap { document in
                let data = document.data()
                return document["eventTitle"] as? String
            }

            // Reload the picker view on the main thread
            DispatchQueue.main.async {
                self.eventTitle.reloadAllComponents()
            }
        }
    }

    // MARK: - UIPickerView DataSource and Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == eventTitle {
            return eventTitles.count
        } else if pickerView == eventStatus {
            return eventStatuses.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == eventTitle {
            return eventTitles[row]
        } else if pickerView == eventStatus {
            return eventStatuses[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == eventTitle {
            let selectedTitle = eventTitles[row]

            // Fetch event document based on title
            db.collection("createEvent").whereField("eventTitle", isEqualTo: selectedTitle).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching event data: \(error.localizedDescription)")
                    return
                }

                if let document = snapshot?.documents.first {
                    self.selectedEventId = document.documentID
                    self.selectedStatus = document["status"] as? String ?? "active"
                    
                    // Set the status picker to the fetched status
                    DispatchQueue.main.async {
                        if let statusIndex = self.eventStatuses.firstIndex(of: self.selectedStatus) {
                            self.eventStatus.selectRow(statusIndex, inComponent: 0, animated: true)
                        }
                    }
                }
            }
        } else if pickerView == eventStatus {
            // Get selected status from picker
            self.selectedStatus = eventStatuses[row]
        }
    }

    // MARK: - Handle Next Button Action

    @IBAction func handleNextButton(_ sender: Any) {
        // Check the UISegmentedControl selection for "Yes" or "No"
        if handleEventDeletion.selectedSegmentIndex == 0 { // "Yes"
            showConfirmationAlert()
        } else { // "No"
            // If "No", save event status and navigate to the next screen
            saveEventStatusToFirestore()
            self.performSegue(withIdentifier: "showNextScreen", sender: self)
        }
    }

    // MARK: - Show Confirmation Alert

    func showConfirmationAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete this event?", preferredStyle: .alert)

        // Add "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteSelectedEventAndNavigate()
        }

        // Add "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            // Save event status and navigate to next screen when "No" is selected
            self.saveEventStatusToFirestore()
            self.performSegue(withIdentifier: "showNextScreen", sender: self)
        }

        // Add actions to the alert
        alert.addAction(yesAction)
        alert.addAction(noAction)

        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Delete Event from Firestore and Navigate

    func deleteSelectedEventAndNavigate() {
        guard let eventId = selectedEventId else {
            print("No event selected.")
            return
        }

        // Delete the event from Firestore
        db.collection("createEvent").document(eventId).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                print("Event successfully deleted!")
                self.performSegue(withIdentifier: "showNextScreen", sender: self)
            }
        }
    }

    // MARK: - Save Event Status to Firestore

    func saveEventStatusToFirestore() {
        guard let eventId = selectedEventId else {
            print("No event selected for status update.")
            return
        }

        // Update the event status in Firestore
        db.collection("createEvent").document(eventId).updateData(["status": selectedStatus]) { error in
            if let error = error {
                print("Error saving status: \(error.localizedDescription)")
            } else {
                print("Event status updated successfully!")
            }
        }
    }

    // MARK: - Prepare for Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNextScreen" {
            // Pass any necessary data to the destination view controller
            if let nextVC = segue.destination as? confirmationScreen3 {
                nextVC.eventTitle = selectedEventId // or any other data you want to pass
            }
        }
    }
}
