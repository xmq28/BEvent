import UIKit
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    // Firestore reference
    let db = Firestore.firestore()

    // Data arrays for events
    var events: [[EventModel]] = []
    var filteredEvents: [[EventModel]] = []
    var filterResualts: [[EventModel]] = []
    
    var sectionTitles: [String] = [
        "Recommended for You",
        "Based on Your Likes",
        "Based on Your Previous Events"
    ]

    var isFiltering = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the navigation title
        self.title = "Bevent"

        // Configure CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Vertical scrolling
        layout.minimumLineSpacing = 10     // Spacing between rows
        layout.minimumInteritemSpacing = 10 // Spacing between items
        collectionView.collectionViewLayout = layout

        // Enable vertical bounce
        collectionView.alwaysBounceVertical = true

        // Configure SearchBar
        searchBar.delegate = self

        if filterResualts.isEmpty {
            // Fetch events from Firebase
            fetchEventsFromFirebase()
        } else {
            // Initialize filtered data with fetched data
            self.isFiltering = true
            self.filteredEvents = self.filterResualts
            self.events = self.filterResualts
            // Reload collection view
            self.collectionView.reloadData()
        }
    }

    func fetchEventsFromFirebase() {
        db.collection("createEvent").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            // Clear existing data
            self.events = []

            // Process documents
            for document in snapshot!.documents {
                let data = document.data()
                
                let title = data["eventTitle"] as? String ?? ""
                let description = data["eventDescription"] as? String ?? ""
                let dateTimestamp = data["eventDateTime"] as? Timestamp ?? nil
                let dateTimeDate = dateTimestamp?.dateValue()
                let dateTime = dateTimeDate?.formatted() ?? ""
                let city = data["eventCity"] as? String ?? ""
                let location = data["eventLocation"] as? String ?? ""
                let category = data["eventCategory"] as? String ?? ""
                let governorate = data["eventGovernorate"] as? String ?? ""
                let image = data["eventImages"] as? String ?? ""
                let price = data["eventPrice"] as? Double ?? nil
                let companyData = data["companyData"] as? [String:String] ?? [:]
                let company = companyData["companyName"] ?? ""
                
                let event = EventModel(
                    title: title,
                    description: description,
                    dateTime: dateTime,
                    city: city,
                    location: location,
                    category: category,
                    governorate: governorate,
                    price: price,
                    company: company,
                    image: image
                )

                // Add event to first section (example logic, customize as needed)
                if self.events.isEmpty {
                    self.events.append([event])
                } else {
                    self.events[0].append(event)
                }
            }

            // Initialize filtered data with fetched data
            self.filteredEvents = self.events

            // Reload collection view
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func filterBtn(_ sender: Any) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

struct EventModel {
    var title: String //eventTitle
    var description: String //eventDescription
    var dateTime: String //eventDateTime
    var city: String //eventCity
    var location: String //eventLocation
    var category: String //eventCategory
    var governorate: String //eventGovernorate
    var price: Double? = nil //eventPrice
    var company: String
    var image: String //eventImages
    //var company: CompanyModel
}

struct CompanyModel {
    var Name: String
    var City: String
    var email: String
    var address: String
    var description: String
    var governorate: String
    var phoneNumber: String
    var organizerName: String
}

// MARK: - UICollectionView DataSource and Delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isFiltering ? filteredEvents.count : events.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredEvents[section].count : events[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 25

        let eventList = isFiltering ? filteredEvents : events
        let event = eventList[indexPath.section][indexPath.row]

        if let url = URL(string: event.image) {
            loadImage(from: url, into: cell.imageView)
        }

        cell.TitleLbl.text = event.title
        cell.locationLbl.text = event.description
        cell.dateLbl.text = event.dateTime

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2 // Adjust for padding
        return CGSize(width: width, height: width + 80)  // Extra height for labels
    }
    
    func loadImage(from url: URL, into imageView: UIImageView) {
        // Create a data task to download the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            // Ensure the response is valid and data is returned
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to create image from data")
                return
            }
            
            // Update the image on the main thread
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume() // Don't forget to start the task
    }
}

// MARK: - UISearchBar Delegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isFiltering = false
            filteredEvents = events
        } else {
            isFiltering = true
            filteredEvents = []

            for section in 0..<events.count {
                let filteredSection = events[section].filter { event in
                    event.title.lowercased().contains(searchText.lowercased()) ||
                    event.description.lowercased().contains(searchText.lowercased()) ||
                    event.dateTime.lowercased().contains(searchText.lowercased())
                }

                if !filteredSection.isEmpty {
                    filteredEvents.append(filteredSection)
                }
            }
        }
        collectionView.reloadData()
    }
}
