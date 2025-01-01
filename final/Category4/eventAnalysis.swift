import UIKit
import FirebaseFirestore

class eventAnalysis: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var eventTitlePicker: UIPickerView!  // Picker view to display event titles
    var eventTitles: [String] = []  // Array to store event titles fetched from Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate and data source for the picker view
        eventTitlePicker.delegate = self
        eventTitlePicker.dataSource = self
        
        // Fetch event titles from Firestore
        fetchEventTitles()
    }

    // MARK: - Fetch Event Titles from Firestore
    func fetchEventTitles() {
        let db = Firestore.firestore()
        
        db.collection("createEvent").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            // Clear previous titles if any
            self.eventTitles.removeAll()
            
            // Loop through the documents and add event titles to the array
            snapshot?.documents.forEach { document in
                if let eventTitle = document["eventTitle"] as? String {
                    self.eventTitles.append(eventTitle)
                }
            }
            
            // Reload the picker view after fetching data
            self.eventTitlePicker.reloadAllComponents()
        }
    }

    // MARK: - UIPickerView DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // One column for event titles
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventTitles.count  // Number of rows will be the number of event titles
    }
    
    // MARK: - UIPickerView Delegate Method
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventTitles[row]  // Display event title for each row
    }
    
    // MARK: - Handle Next Button Action
    @IBAction func handleNextButton(_ sender: Any) {
        // Get the selected row from the picker view
        let selectedRow = eventTitlePicker.selectedRow(inComponent: 0)
        let selectedEventTitle = eventTitles[selectedRow]
        
        // Debugging: Print selected event title
        print("Selected Event Title: \(selectedEventTitle)")
        
        // Perform segue to eventAnalysis2 and pass the selected event title
        performSegue(withIdentifier: "showEventAnalysis2", sender: selectedEventTitle)
    }

    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventAnalysis2", let destinationVC = segue.destination as? eventAnalysis2 {
            print("Preparing for segue to eventAnalysis2")  // Debug print
            if let selectedEventTitle = sender as? String {
                destinationVC.selectedEventTitle = selectedEventTitle
            }
        }
    }
}
