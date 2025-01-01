import UIKit
import FirebaseFirestore

class AlterStatusViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!

    var db = Firestore.firestore()
    var statuses = ["Upcoming", "Cancelled", "Completed"]
    var selectedEvent: [String: Any]? // Event passed from previous screen
    var selectedStatus: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        statusPicker.delegate = self
        statusPicker.dataSource = self

        if let event = selectedEvent, let currentStatus = event["status"] as? String {
            if let index = statuses.firstIndex(of: currentStatus) {
                statusPicker.selectRow(index, inComponent: 0, animated: false)
                selectedStatus = currentStatus
            }
        }
    }

    // MARK: - Picker View Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }

    // MARK: - Picker View Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStatus = statuses[row]
    }

    @IBAction func saveStatus(_ sender: UIButton) {
        guard let selectedStatus = selectedStatus,
              let eventId = selectedEvent?["id"] as? String else { return }

        // Update the event's status in Firestore
        db.collection("events").document(eventId).updateData(["status": selectedStatus]) { error in
            if let error = error {
                print("Error updating status: \(error)")
            } else {
                // Show an alert after saving
                let alert = UIAlertController(title: "Success", message: "Status has been altered.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
