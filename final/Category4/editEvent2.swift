import UIKit
import FirebaseFirestore
import FirebaseStorage


// MARK: - CustomEvent Model
struct CustomEvent {
    var title: String?
    var description: String?
    var location: String?
    var city: String?
    var price: Double
    var category: String?
    var governorate: String?
    var eventDateTime: Date?
    var companyData: [String: Any]?
    var eventImages: [String]?  // Array of image URLs or paths
}

class EditEvent2: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Outlets for the various UI components
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var pickImage: UIImageView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var governorate: UIPickerView!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var category: UIPickerView!
    @IBOutlet weak var eventTitle: UITextField!
    
    // Company Data Outlets
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var organizerName: UITextField!
    @IBOutlet weak var companyCity: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var companyDescription: UITextView!
    @IBOutlet weak var companyGovernorate: UIPickerView!
    @IBOutlet weak var companyAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    // Arrays to hold the data for categories and governorates
    let categories = ["Category", "Art", "Sports", "Food", "Workshops", "Family", "Technology", "Nature", "Gaming"]
    let governorates = ["Governorate", "Muharraq", "Capital", "Northern", "Southern"]

    // Event data received from the previous screen
    var event: CustomEvent?
    
    // Track the original event title (ID) so we can update it
    var originalEventTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the pickers
        category.delegate = self
        category.dataSource = self
        governorate.delegate = self
        governorate.dataSource = self
        companyGovernorate.delegate = self
        companyGovernorate.dataSource = self
        
        // Update the UI with the fetched event data
        if let event = event {
            originalEventTitle = event.title  // Keep track of the original event title (ID)
            updateUIWithEventData(event: event)
        }
    }

    // Update the UI with the fetched event data
    func updateUIWithEventData(event: CustomEvent) {
        // Event fields
        eventTitle.text = event.title ?? "No Title"
        Description.text = event.description ?? "No Description"
        location.text = event.location ?? "No Location"
        city.text = event.city ?? "No City"
        price.text = "\(event.price)" // Display price as a String in the UITextField

        // Category and Governorate Picker
        if let category = event.category, let index = categories.firstIndex(of: category) {
            self.category.selectRow(index, inComponent: 0, animated: false)
        }
        if let governorate = event.governorate, let index = governorates.firstIndex(of: governorate) {
            self.governorate.selectRow(index, inComponent: 0, animated: false)
        }

        // Event Date
        if let eventDateTime = event.eventDateTime {
            dateTime.date = eventDateTime
        }

        // Load image from Firestore URL if available
        if let eventImages = event.eventImages, !eventImages.isEmpty, let imageURLString = eventImages.first, let imageURL = URL(string: imageURLString) {
            loadImageFromURL(url: imageURL)
        }


    
        // Company-related fields (ensure the company data is correctly displayed)
        if let companyData = event.companyData {
            companyName.text = companyData["companyName"] as? String ?? "No Company Name"
            organizerName.text = companyData["organizerName"] as? String ?? "No Organizer Name"
            companyCity.text = companyData["companyCity"] as? String ?? "No City"
            email.text = companyData["email"] as? String ?? "No Email"
            companyDescription.text = companyData["companyDescription"] as? String ?? "No Description"
            companyGovernorate.selectRow(governorates.firstIndex(of: companyData["companyGovernorate"] as? String ?? "") ?? 0, inComponent: 0, animated: false)
            companyAddress.text = companyData["companyAddress"] as? String ?? "No Address"
            phoneNumber.text = companyData["phoneNumber"] as? String ?? "No Phone Number"
        }
    }

    // Function to load image from URL into UIImageView
    func loadImageFromURL(url: URL) {
        // Use a background queue to download the image
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.pickImage.image = image
                    }
                }
            }
        }
    }

    // MARK: - Next Button Action
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard var event = event else {
            print("Event is nil, cannot update.")
            return
        }

        // Safely unwrap and assign values from the UI to the event object
        event.description = Description.text ?? ""
        event.location = location.text ?? ""
        event.city = city.text ?? ""

        // Safely unwrap and parse price as Double
        if let priceText = price.text, let priceValue = Double(priceText) {
            event.price = priceValue
        } else {
            event.price = 0
        }

        // Safely unwrap category and governorate selections
        event.category = categories[category.selectedRow(inComponent: 0)]
        event.governorate = governorates[governorate.selectedRow(inComponent: 0)]
        event.eventDateTime = dateTime.date

        // Collect the new company-related data
        event.companyData?["companyName"] = companyName.text ?? ""
        event.companyData?["organizerName"] = organizerName.text ?? ""
        event.companyData?["companyCity"] = companyCity.text ?? ""
        event.companyData?["email"] = email.text ?? ""
        event.companyData?["companyDescription"] = companyDescription.text ?? ""
        event.companyData?["companyGovernorate"] = governorates[companyGovernorate.selectedRow(inComponent: 0)]
        event.companyData?["companyAddress"] = companyAddress.text ?? ""
        event.companyData?["phoneNumber"] = phoneNumber.text ?? ""

        // Ensure data is properly being passed
        print("Updated Event: \(event)")

        // Save the updated event data back to Firestore
        saveEventToFirestore(event: event) {
            // After saving, delete the old event document
            self.deleteOldEventDocument(eventTitle: self.originalEventTitle ?? "")
            
            // After saving, perform segue to the confirmation screen
            self.performSegue(withIdentifier: "confirmationScreen2", sender: self)
        }
    }

    // MARK: - Save Event Data to Firestore
    func saveEventToFirestore(event: CustomEvent, completion: @escaping () -> Void) {
        let db = Firestore.firestore()

        // Generate a new unique document ID (or use the current title if you want to maintain it)
        let newEventID = UUID().uuidString  // Generate new event ID
        let eventData: [String: Any] = [
            "title": event.title ?? "",
            "description": event.description ?? "",
            "location": event.location ?? "",
            "city": event.city ?? "",
            "price": event.price,
            "category": event.category ?? "",
            "governorate": event.governorate ?? "",
            "eventDateTime": event.eventDateTime ?? Date(), // Default to current date if nil
            "eventImages": event.eventImages ?? [] // Store the array of image URLs in Firestore

        ]

        print("Saving event data: \(eventData)")

        // Save new event data under a new document ID
        db.collection("createEvent").document(newEventID).setData(eventData) { error in
            if let error = error {
                print("Error saving event data: \(error.localizedDescription)")
            } else {
                print("Event successfully updated.")
                // After saving, save company data
                self.saveCompanyDataToFirestore(event: event, newEventID: newEventID, completion: completion)
            }
        }
    }

    func saveCompanyDataToFirestore(event: CustomEvent, newEventID: String, completion: @escaping () -> Void) {
        guard !newEventID.isEmpty else {
            print("Error: New event ID is empty")
            return
        }

        // Save company data (which is in the companyData map)
        Firestore.firestore().collection("createEvent").document(newEventID).setData(["companyData": event.companyData ?? [:]]) { error in
            if let error = error {
                print("Error saving company data: \(error.localizedDescription)")
            } else {
                print("Company data successfully updated.")
                // After saving company data, execute the completion
                completion()
            }
        }
    }

    // MARK: - Delete Old Event Document
    func deleteOldEventDocument(eventTitle: String) {
        let db = Firestore.firestore()
        
        // Delete the old event document using the original event title
        db.collection("createEvent").document(eventTitle).delete { error in
            if let error = error {
                print("Error deleting old event: \(error.localizedDescription)")
            } else {
                print("Old event successfully deleted.")
            }
        }
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == category {
            return categories.count
        } else if pickerView == governorate || pickerView == companyGovernorate {
            return governorates.count
        }
        return 0
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == category {
            return categories[row]
        } else if pickerView == governorate || pickerView == companyGovernorate {
            return governorates[row]
        }
        return nil
    }

    // MARK: - Image Picker
    @IBAction func pickImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the picked image to the UIImageView
            pickImage.image = image

            // Optionally, upload the image to Firebase Storage
            uploadImageToFirebase(image: image)
        } else {
            print("No image selected")
        }

        dismiss(animated: true, completion: nil)
    }


    func uploadImageToFirebase(image: UIImage) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("event_images/\(UUID().uuidString).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            print("Image URL: \(downloadURL.absoluteString)")
                            self.updateEventImageURL(url: downloadURL.absoluteString)
                        }
                    }
                }
            }
        }
    }

    func updateEventImageURL(url: String) {
        if event?.eventImages == nil {
            event?.eventImages = []
        }
        event?.eventImages?.append(url)


    }
}
