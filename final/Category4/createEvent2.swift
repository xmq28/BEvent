import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore

class CreateEvent2: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var event: Event?  // Property to store passed event data

    // UI Outlets
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var organizerName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var companyAddress: UITextField!
    @IBOutlet weak var companyCity: UITextField!
    @IBOutlet weak var companyDescription: UITextView!
    @IBOutlet weak var companyGovernorate: UIPickerView!  // UIPickerView for governorates
    @IBOutlet weak var nextButton2: UIButton!

    // List of available governorates
    let governorates = ["Governorate", "Muharraq", "Capital", "Northern", "Southern"]
    var selectedCompanyGovernorate: String?  // Stores the selected governorate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the UIPickerView
        companyGovernorate.dataSource = self
        companyGovernorate.delegate = self
        
        // Pre-fill event data if available
        if let eventData = event {
            // Optional: Prefill data if available (you can uncomment if you want to display pre-existing data)
            // companyName.text = eventData.companyName
            // companyDescription.text = eventData.companyDescription
        }

        // Setup action for the next button
        nextButton2.addTarget(self, action: #selector(handleNextButton2), for: .touchUpInside)
    }

    // MARK: - UIPickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // Only one component for governorates
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return governorates.count  // Number of rows equal to the number of governorates
    }

    // MARK: - UIPickerViewDelegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return governorates[row]  // Display governorate name for each row
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCompanyGovernorate = governorates[row]  // Store the selected governorate
    }

    @IBAction func handleNextButton2(_ sender: Any) {
        guard let event = event else { return }

        // Validate each field for non-null and non-empty values
        guard let companyNameText = companyName.text, !companyNameText.isEmpty else {
            showError("Company name is required.")
            return
        }
        guard let organizerNameText = organizerName.text, !organizerNameText.isEmpty else {
            showError("Organizer name is required.")
            return
        }
        guard let emailText = email.text, !emailText.isEmpty else {
            showError("Email is required.")
            return
        }
        guard let phoneNumberText = phoneNumber.text, !phoneNumberText.isEmpty else {
            showError("Phone number is required.")
            return
        }
        
        // Validate phone number (should be exactly 8 digits)
        guard isValidPhoneNumber(phoneNumberText) else {
            showError("Phone number should be exactly 8 digits.")
            return
        }

        guard let companyAddressText = companyAddress.text, !companyAddressText.isEmpty else {
            showError("Company address is required.")
            return
        }
        guard let companyCityText = companyCity.text, !companyCityText.isEmpty else {
            showError("Company city is required.")
            return
        }
        
        // Check if governorate is selected (must not be nil or empty)
        guard let selectedGovernorate = selectedCompanyGovernorate, !selectedGovernorate.isEmpty else {
            showError("Governorate is required.")
            return
        }

        // Now, the price is passed through the `event` object, so no need to validate again.
        let price = event.price // This is the price passed from CreateEvent
        
        // Collect company data
        let companyData: [String: Any] = [
            "companyName": companyNameText,
            "organizerName": organizerNameText,
            "email": emailText,
            "phoneNumber": phoneNumberText,
            "companyAddress": companyAddressText,
            "companyCity": companyCityText,
            "companyGovernorate": selectedCompanyGovernorate, // governorate must be selected
            "companyDescription": companyDescription.text ?? ""
        ]
        
        // Combine event data and company data into one document
        var combinedData: [String: Any] = [
            "eventTitle": event.title ?? "",
            "eventDescription": event.description ?? "",
            "eventLocation": event.location ?? "",
            "eventCity": event.city ?? "",
            "eventPrice": price,  // Store the valid price here
            "eventCategory": event.category ?? "",
            "eventGovernorate": event.governorate ?? "",
            "eventDateTime": event.eventDateTime ?? Date(),
        ]
        
        // Add images to the combined data (if available)
        if let eventImages = event.images, !eventImages.isEmpty {
            combinedData["eventImages"] = eventImages
        }

        // Merge with company data
        combinedData["companyData"] = companyData
        
        // Save combined data to Firestore
        saveCombinedDataToFirestore(data: combinedData)
    }

    // Helper function to show error messages
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Helper function to validate phone number (should be exactly 8 digits)
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[0-9]{8}$"  // Exactly 8 digits
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberTest.evaluate(with: phoneNumber)
    }

    func saveCombinedDataToFirestore(data: [String: Any]) {
        let db = Firestore.firestore()

        // Change "events" to "createEvent" to save to the correct collection
        let eventDocRef = db.collection("createEvent").document()  // Auto-generated document ID
        
        // Set the data in the "createEvent" collection
        eventDocRef.setData(data) { error in
            if let error = error {
                // If there's an error, print the error message
                print("Error saving combined data to createEvent: \(error.localizedDescription)")
            } else {
                // If the data is saved successfully, print a success message
                print("Combined data successfully saved to createEvent.")
                
                // Now, create a sub-collection "createEvents" inside the "createEvent" document
                let createEventsRef = eventDocRef.collection("createEvents")
                
                // Prepare the sub-event data (example, can be more specific)
                let eventSubData: [String: Any] = [
                    "subEventName": data["eventTitle"] ?? "",
                    "subEventDescription": data["eventDescription"] ?? "",
                    "eventCity": data["eventCity"] ?? "",
                    "eventLocation": data["eventLocation"] ?? "",
                    // Add other fields as necessary
                ]
                
                // Add the sub-event data to the "createEvents" sub-collection
                createEventsRef.addDocument(data: eventSubData) { error in
                    if let error = error {
                        print("Error adding sub-collection document to createEvents: \(error.localizedDescription)")
                    } else {
                        print("Sub-event successfully added to createEvents.")
                        
                        // After saving, navigate to the ConfirmationScreen
                        self.performSegue(withIdentifier: "toConfirmationScreen", sender: self)
                    }
                }
            }
        }
    }
}
