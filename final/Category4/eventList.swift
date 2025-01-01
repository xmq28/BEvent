import UIKit
import FirebaseFirestore
import FirebaseStorage

class eventList: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    var db: Firestore!
    var storage: Storage!
    
    // To hold all dynamically created containers
    var eventContainers: [UIView] = []
    var totalContainerHeight: CGFloat = 0  // To keep track of the total height of all event containers

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Firestore and Firebase Storage
        db = Firestore.firestore()
        storage = Storage.storage()
        
        // Fetch event data from Firestore
        fetchEventData()
    }
    
    // MARK: - Fetch Data from Firestore
    func fetchEventData() {
        db.collection("createEvent").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            // Clear previous containers before adding new ones
            self.eventContainers.forEach { $0.removeFromSuperview() }
            self.eventContainers.removeAll()
            self.totalContainerHeight = 0  // Reset the total height
            
            guard let snapshot = snapshot else {
                print("No events found.")
                return
            }

            // Loop through the documents and create containers for each event
            // Reversed order to display new events on top
            for document in snapshot.documents.reversed() {
                let eventTitle = document["eventTitle"] as? String ?? "No Title"
                let imageUrl = document["eventImages"] as? String ?? ""
                
                // Create a container for each event
                self.createEventContainer(eventTitle: eventTitle, imageUrl: imageUrl)
            }

            // Update the scroll view content size based on the total height
            self.updateScrollViewContentSize()
        }
    }
    
    // MARK: - Create Event Container for each Document
    func createEventContainer(eventTitle: String, imageUrl: String) {
        // Create a new container for each event
        let eventContainer = UIView()
        eventContainer.translatesAutoresizingMaskIntoConstraints = false
        eventContainer.backgroundColor = UIColor(hex: "#e2b4ad") // Set the background color of the container
        eventContainer.layer.cornerRadius = 10
        eventContainer.layer.masksToBounds = true
        
        // Create an image view for the event image (background image)
        let eventImageView = UIImageView()
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        
        // Create a UITextField to display the event title
        let eventTitleField = UITextField()
        eventTitleField.translatesAutoresizingMaskIntoConstraints = false
        eventTitleField.text = eventTitle
        eventTitleField.font = UIFont.boldSystemFont(ofSize: 18)
        eventTitleField.textColor = .white  // White text for better visibility
        eventTitleField.textAlignment = .center  // Center the text
        eventTitleField.isUserInteractionEnabled = false  // Make the text field non-editable (if you don't want the user to edit)
        eventTitleField.borderStyle = .roundedRect
        eventTitleField.layer.cornerRadius = 8
        
        // Set the background color to the hex value "#cc6e5e"
        eventTitleField.backgroundColor = UIColor(hex: "#cc6e5e") // This uses a custom UIColor extension to convert hex
        
        // Add the image view and title field to the event container
        eventContainer.addSubview(eventImageView)
        eventContainer.addSubview(eventTitleField)
        
        // Insert the event container at the top of the parent container
        self.container.insertSubview(eventContainer, at: 0)
        
        // Add the event container to the list of event containers
        eventContainers.insert(eventContainer, at: 0)
        
        // Constraints for the event container (height and width should be dynamic)
        eventContainer.widthAnchor.constraint(equalTo: self.container.widthAnchor, constant: -20).isActive = true
        
        // Dynamic height based on the content, we set a fixed height for the container for simplicity
        let eventContainerHeight: CGFloat = 250  // Total height for the event container
        let imageHeight: CGFloat = eventContainerHeight - 60 // Leave 60 points for the text field at the bottom
        eventContainer.heightAnchor.constraint(equalToConstant: eventContainerHeight).isActive = true
        
        // If there are multiple event containers, position them one after the other
        if let nextContainer = eventContainers.dropFirst().first {
            eventContainer.topAnchor.constraint(equalTo: nextContainer.bottomAnchor, constant: 10).isActive = true
        } else {
            eventContainer.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 10).isActive = true
        }
        
        // Constraints for the image view (fill the container, leaving space at the bottom for the title field)
        eventImageView.topAnchor.constraint(equalTo: eventContainer.topAnchor).isActive = true
        eventImageView.leftAnchor.constraint(equalTo: eventContainer.leftAnchor).isActive = true
        eventImageView.rightAnchor.constraint(equalTo: eventContainer.rightAnchor).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        
        // Constraints for the event title field (place it at the bottom of the container, with some padding)
        eventTitleField.leftAnchor.constraint(equalTo: eventContainer.leftAnchor, constant: 10).isActive = true
        eventTitleField.rightAnchor.constraint(equalTo: eventContainer.rightAnchor, constant: -10).isActive = true
        eventTitleField.bottomAnchor.constraint(equalTo: eventContainer.bottomAnchor, constant: -10).isActive = true
        
        // Update the total height of the containers
        self.totalContainerHeight += eventContainerHeight + 10 // Each container has a height of 250 + 10 for spacing
        
        // Load the image from URL and set it
        if !imageUrl.isEmpty {
            loadImage(from: imageUrl) { image in
                if let image = image {
                    // Create a UIImageView once the image is fetched
                    self.displayImage(image, in: eventContainer)
                }
            }
        }
    }
    
    // MARK: - Load Image from URL (as UIImage)
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            completion(nil)
            return
        }

        // Fetch the image data asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Check if the data is valid and can be converted to an image
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image data.")
                completion(nil)
                return
            }

            // Return the image to the completion handler
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()  // Don't forget to call resume to start the data task
    }
    
    // MARK: - Display Image as UIImage
    func displayImage(_ image: UIImage, in container: UIView) {
        // Create the UIImageView and set its image
        let eventImageView = UIImageView(image: image)
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        
        // Add the image view to the container
        container.addSubview(eventImageView)
        
        // Constraints for the image view (fill the entire container, except for space reserved for the title)
        eventImageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        eventImageView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        eventImageView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 190).isActive = true // 250 - 60 for title field
    }
    
    // MARK: - Update ScrollView Content Size
    func updateScrollViewContentSize() {
        // Safely unwrap scrollView and container
        guard let scrollView = scrollView, let container = container else {
            print("ScrollView or Container is nil!")
            return
        }
        
        // Update the content size of the scroll view based on the total height of all event containers
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: self.totalContainerHeight)
    }
}

// MARK: - UIColor Extension to Handle Hex Color
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
