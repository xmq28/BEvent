
import UIKit
import FirebaseFirestore

class editEvent: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var selectEvent: UIPickerView!

    var eventTitles: [String] = []       // Array to hold the event titles
    var selectedEventTitle: String?      // Variable to store the selected event title
    var selectedEvent: CustomEvent?      // Change to CustomEvent type

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the picker view delegate and dataSource
        selectEvent.delegate = self
        selectEvent.dataSource = self

        // Fetch event titles from Firestore
        fetchEventTitles()
    }

    // Function to fetch event titles from Firestore
    func fetchEventTitles() {
        let db = Firestore.firestore()

        db.collection("createEvent").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                print("No snapshot data.")
                return
            }

            print("Documents fetched: \(snapshot.documents.count)")  // Check how many documents are fetched

            // Log full document data for debugging
            self.eventTitles = snapshot.documents.compactMap { document in
                let data = document.data()  // Full document data
                print("Document data: \(data)")  // Debugging: Print the entire document

                // Return the 'eventTitle' field for each document
                return document["eventTitle"] as? String
            }

            // Check if eventTitles is populated
            if self.eventTitles.isEmpty {
                print("No event titles found.")
            } else {
                print("Event Titles: \(self.eventTitles)")  // Print all titles fetched
            }

            // Reload the picker view on the main thread
            DispatchQueue.main.async {
                self.selectEvent.reloadAllComponents() // Reload the picker view after fetching titles
            }
        }
    }

    // Action for the "Next" button
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let event = selectedEvent {
            // Pass the selected event data to the next screen
            performSegue(withIdentifier: "toEditEvent2", sender: event)
        } else {
            // Optionally, show an alert if no event is selected
            let alert = UIAlertController(title: "Selection Required", message: "Please select an event to proceed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // Prepare for segue and pass the selected event data to EditEvent2
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditEvent2", let event = sender as? CustomEvent {  // Expect CustomEvent here
            if let destinationVC = segue.destination as? EditEvent2 {
                destinationVC.event = event
            }
        }
    }

    // Fetch the event data from Firestore
    func fetchEventData(eventTitleText: String) {
        let db = Firestore.firestore()

        db.collection("createEvent")
            .whereField("eventTitle", isEqualTo: eventTitleText)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching event data: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No event found with that title.")
                    return
                }

                // Parse the event data and assign it to the selectedEvent object
                self.selectedEvent = CustomEvent(
                    title: document["eventTitle"] as? String,
                    description: document["eventDescription"] as? String,
                    location: document["eventLocation"] as? String,
                    city: document["eventCity"] as? String,
                    price: document["eventPrice"] as? Double ?? 0.0,
                    category: document["eventCategory"] as? String,
                    governorate: document["eventGovernorate"] as? String,
                    eventDateTime: document["eventDateTime"] as? Date,
                    companyData: document["companyData"] as? [String: Any] // Ensure companyData is also parsed
                )
            }
    }
}

// MARK: - UIPickerViewDataSource and UIPickerViewDelegate
extension editEvent: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventTitles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventTitles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEventTitle = eventTitles[row]

        // Fetch the selected event data from Firestore based on the title
        fetchEventData(eventTitleText: selectedEventTitle ?? "")
    }
}
