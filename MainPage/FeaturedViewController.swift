import UIKit
import FirebaseFirestore

class FeaturedViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Variables
    var events = [EventModel]()
    var filteredEvents = [EventModel]()
    var isSearching = false
    let db = Firestore.firestore()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        // Set Layout for Collection View
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.frame.width - 32, height: 250) // Set size
        layout.minimumLineSpacing = 16
        collectionView.collectionViewLayout = layout
        
        // Fetch Events from Firebase
        fetchEventsFromFirebase()
    }
    
    // MARK: - Firebase Fetch
    func fetchEventsFromFirebase() {
        db.collection("createEvent").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            self.events.removeAll()
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

                self.events.append(event)
            }
            self.filteredEvents = self.events
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

// MARK: - Collection View Methods
extension FeaturedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredEvents.count : events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        let event = isSearching ? filteredEvents[indexPath.item] : events[indexPath.item]
        cell.configure(with: event)
        return cell
    }
}

// MARK: - Search Bar Methods
extension FeaturedViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredEvents = events
        } else {
            isSearching = true
            filteredEvents = events.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredEvents = events
        collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
}

