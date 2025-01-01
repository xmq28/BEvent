import UIKit
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import Cloudinary

// MARK: - Event Model
class Event {
    var title: String?
    var description: String?
    var location: String?
    var city: String?
    var price: Double = 0.0
    var category: String?
    var governorate: String?
    var images: [String]? // Store image paths as an array of strings
    var eventDateTime: Date?

    // Company-related fields
    var companyName: String?
    var organizerName: String?
    var email: String?
    var phoneNumber: String?
    var companyAddress: String?
    var companyCity: String?
    var companyGovernorate: String?
    var companyDescription: String?
    
    // Add a property to store document ID
    var documentID: String?  // This will hold the Firestore document ID
    
    // Initializer with company-related fields added
    init(title: String? = nil, description: String? = nil, location: String? = nil, city: String? = nil, price: Double = 0.0, category: String? = nil, governorate: String? = nil, images: [String]? = nil, eventDateTime: Date? = nil, companyName: String? = nil, organizerName: String? = nil, email: String? = nil, phoneNumber: String? = nil, companyAddress: String? = nil, companyCity: String? = nil, companyGovernorate: String? = nil, companyDescription: String? = nil) {
        self.title = title
        self.description = description
        self.location = location
        self.city = city
        self.price = price
        self.category = category
        self.governorate = governorate
        self.images = images
        self.eventDateTime = eventDateTime
        self.companyName = companyName
        self.organizerName = organizerName
        self.email = email
        self.phoneNumber = phoneNumber
        self.companyAddress = companyAddress
        self.companyCity = companyCity
        self.companyGovernorate = companyGovernorate
        self.companyDescription = companyDescription
    }
}

// MARK: - CreateEvent ViewController
class createEvent: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, PHPickerViewControllerDelegate, UITextFieldDelegate {

    var event = Event()

    // MARK: - Outlets
    @IBOutlet weak var category: UIPickerView!
    @IBOutlet weak var governorate: UIPickerView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var pickImage: UIImageView!
    @IBOutlet weak var eventDateTime: UIDatePicker!

    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventCity: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventPrice: UITextField!
    @IBOutlet weak var nextButton1: UIButton!

    // MARK: - Data
    let categories = ["Category", "Art", "Sports", "Food", "Workshops", "Family", "Technology", "Nature", "Gaming"]
    let governorates = ["Governorate", "Muharraq", "Capital", "Northern", "Southern"]

    var selectedCategory: String?
    var selectedGovernorate: String?
    var selectedImages: [UIImage] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFieldDelegates()
        setupPickers()
        setupPickImageButton()

        if let eventPrice = eventPrice {
            eventPrice.keyboardType = .numberPad
        }

        if let nextButton1 = nextButton1 {
            nextButton1.addTarget(self, action: #selector(handleNextButton1), for: .touchUpInside)
        }

        // Restore event data if it exists
        if let title = event.title {
            eventTitle.text = title
        }
        if let description = event.description {
            eventDescription.text = description
        }
        if let city = event.city {
            eventCity.text = city
        }
        if let location = event.location {
            eventLocation.text = location
        }
        if event.price >= 0 {
            eventPrice.text = String(event.price)
        }
    }

    // MARK: - Actions

    @IBAction func handleNextButton1(_ sender: Any) {
        // Ensure the price is a valid double
        guard let priceText = eventPrice.text, let price = Double(priceText), price >= 0 else {
            showError("Price should be a valid positive number.")
            return
        }

        // Ensure that required fields are not empty
        guard let eventTitleText = eventTitle.text, !eventTitleText.isEmpty else {
            showError("Event title is required.")
            return
        }
        guard let eventDescriptionText = eventDescription.text, !eventDescriptionText.isEmpty else {
            showError("Event description is required.")
            return
        }
        guard let eventCityText = eventCity.text, !eventCityText.isEmpty else {
            showError("Event city is required.")
            return
        }
        guard let eventLocationText = eventLocation.text, !eventLocationText.isEmpty else {
            showError("Event location is required.")
            return
        }
        
        // Ensure category is selected
        guard let selectedCategory = selectedCategory, selectedCategory != "Category" else {
            showError("Event category is required.")
            return
        }
        
        // Ensure governorate is selected
        guard let selectedGovernorate = selectedGovernorate, selectedGovernorate != "Governorate" else {
            showError("Event governorate is required.")
            return
        }

        // Ensure at least one image is selected
        guard !selectedImages.isEmpty else {
            showError("At least one image is required.")
            return
        }

        // Update event object with validated values
        event.title = eventTitleText
        event.description = eventDescriptionText
        event.city = eventCityText
        event.location = eventLocationText
        event.price = price  // Store the price
        event.eventDateTime = eventDateTime.date
        event.category = selectedCategory
        event.governorate = selectedGovernorate

        // Debug print the event object
        print("Event data (Page 1):", event)

        // Perform segue to the next screen
        performSegue(withIdentifier: "toCreateEvent2", sender: self)
    }

    // MARK: - Helper Functions
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Prepare data before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateEvent2" {
            if let destinationVC = segue.destination as? CreateEvent2 {
                // Pass the 'event' object to the next view controller
                destinationVC.event = event
            }
        }
    }

    func saveEventToFirestore(event: Event) {
        let db = Firestore.firestore()
        
        // Prepare event data
        var eventData: [String: Any] = [
            "title": event.title ?? "",
            "description": event.description ?? "",
            "location": event.location ?? "",
            "city": event.city ?? "",
            "price": event.price,
            "category": event.category ?? "",
            "governorate": event.governorate ?? "",
            "eventDateTime": event.eventDateTime ?? Date(),
        ]
        
        // Upload images to Firebase Storage and get the paths
        uploadImagesToStorage(images: selectedImages) { imagePaths in
            // Ensure there are image URLs returned
            if imagePaths.isEmpty {
                print("No images uploaded, cannot save event.")
                return
            }

            // Join image paths into a comma-separated string
            let eventImagePaths = imagePaths.joined(separator: ",")
            eventData["eventImage"] = eventImagePaths  // Save the image URLs under the "eventImage" field

            // Debug print eventData to ensure "eventImage" contains the correct data
            print("Saving event data to Firestore: \(eventData)")

            // Create a new document in the "createEvent" collection (with auto-generated ID)
            let eventDocRef = db.collection("createEvent").document()  // Auto-generate ID for the parent document

            // Set the event data in the "createEvent" document
            eventDocRef.setData(eventData) { error in
                if let error = error {
                    print("Error adding document to createEvent: \(error.localizedDescription)")
                } else {
                    print("Event successfully added to createEvent.")

                    // Now, create the sub-collection "createEvents" inside the parent document
                    let createEventsRef = eventDocRef.collection("createEvents")

                    // Prepare the sub-event data to be stored in the "createEvents" sub-collection
                    let eventSubData: [String: Any] = [
                        "subEventName": event.title ?? "",
                        "subEventDescription": event.description ?? "",
                        "eventCity": event.city ?? "",
                        "eventLocation": event.location ?? "",
                    ]

                    // Add the event data to the "createEvents" sub-collection
                    createEventsRef.addDocument(data: eventSubData) { error in
                        if let error = error {
                            print("Error adding sub-collection document to createEvents: \(error.localizedDescription)")
                        } else {
                            print("Sub-event successfully added to createEvents.")
                        }
                    }
                }
            }
        }
    }

    func uploadImagesToStorage(images: [UIImage], completion: @escaping ([String]) -> Void) {
        let storage = Storage.storage()
        var imagePaths: [String] = []
        let group = DispatchGroup()

        for image in images {
            group.enter()

            // Convert the image to data and upload
            if let imageData = image.jpegData(compressionQuality: 0.75) {
                
                // Create a unique storage reference for the image
                let storageRef = storage.reference().child("event_images/\(UUID().uuidString).jpg")
                
                // Upload the image data to Firebase Storage
                storageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("Error uploading image: \(error)")
                        group.leave()
                    } else {
                        // Get the path to the uploaded image in Firebase Storage
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                print("Error downloading image URL: \(error)")
                            } else if let url = url {
                                imagePaths.append(url.absoluteString) // Save the URL of the uploaded image
                            }
                            group.leave()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(imagePaths)  // Return the image URLs
        }
    }


    private func setupTextFieldDelegates() {
        eventTitle.delegate = self
        eventLocation.delegate = self
        eventCity.delegate = self
        eventPrice.delegate = self
    }

    private func setupPickers() {
        category.dataSource = self
        category.delegate = self
        governorate.dataSource = self
        governorate.delegate = self
    }

    private func setupPickImageButton() {
        pickImageButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == category {
            return categories.count
        } else {
            return governorates.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == category {
            return categories[row]
        } else {
            return governorates[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == category {
            selectedCategory = categories[row]
        } else if pickerView == governorate {
            selectedGovernorate = governorates[row]
        }
    }

    @objc private func openImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5  // Allow up to 5 images
        configuration.filter = .images   // Only allow images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        selectedImages = []  // Clear previous selections
        pickImage.subviews.forEach { $0.removeFromSuperview() }

        var xOffset: CGFloat = 10 // Start position for the images

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    self?.selectedImages.append(image)
                    DispatchQueue.main.async {
                        self?.updatePickImageViews() // Update the image view with new images
                    }
                }
            }
        }
    }

    func pickerDidCancel(_ picker: PHPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // Update the pickImage view with the selected images
    private func updatePickImageViews() {
        pickImage.subviews.forEach { $0.removeFromSuperview() }

        var xPosition: CGFloat = 10 // Starting position for the first image

        for image in selectedImages {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: xPosition, y: 10, width: 60, height: 60) // Set size of image
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true

            pickImage.addSubview(imageView)

            xPosition += 70 // Adjust for spacing between images
        }
    }
}
