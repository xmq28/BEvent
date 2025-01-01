import UIKit
import Firebase
import FirebaseFirestore

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var catPick: UIPickerView!
    @IBOutlet weak var locPick: UIPickerView!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var agePick: UIPickerView!
    @IBOutlet weak var datePick: UIDatePicker!
    @IBOutlet weak var showBtn: UIButton!

    // Variables to store selected filter values
    var selectedCategory: String?
    var selectedLocation: String?
    var selectedPrice: String?
    var selectedAge: String?
    var selectedDate: Date?

    // Picker Data
    let categories = [
        "All",
        "Art",
        "Sports",
        "Food",
        "Workshops",
        "Family",
        "Technology",
        "Nature",
        "Gaming"
    ]
    let locations = ["All", "Sukhir", "Hidd", "Manama", "Riffa", "Seef"]
    //let ages = ["All Ages", "18+", "21+"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickers()
    }

    func setupPickers() {
        catPick.delegate = self
        catPick.dataSource = self

        locPick.delegate = self
        locPick.dataSource = self

        agePick.delegate = self
        agePick.dataSource = self
    }

    // Picker View DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case catPick:
            return categories.count
        case locPick:
            return locations.count
        //case agePick:
        //    return ages.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case catPick:
            return categories[row]
        case locPick:
            return locations[row]
        //case agePick:
        //    return ages[row]
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case catPick:
            selectedCategory = categories[row]
        case locPick:
            selectedLocation = locations[row]
        //case agePick:
        //    selectedAge = ages[row]
        default:
            break
        }
    }

    // Action for 'Show Results' button
    @IBAction func showResultsButtonTapped(_ sender: UIButton) {
        captureFilterValues()
        fetchFilteredData()
    }

    // Capture filter values
    func captureFilterValues() {
        selectedPrice = priceTxt.text
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = datePick.date
    }

    // Fetch filtered data from Firebase
    func fetchFilteredData() {
        let db = Firestore.firestore()
        var query: Query = db.collection("createEvent") // Replace 'events' with your collection name

        // Apply filters based on user input
        if let category = selectedCategory, !category.isEmpty {
            if category != "All" {
                query = query.whereField("eventCategory", isEqualTo: category)
            }
        }
        if let location = selectedLocation, !location.isEmpty {
            if location != "All" {
                query = query.whereField("eventCity", isEqualTo: location)
            }
        }
        if let price = selectedPrice, !price.isEmpty {
            if price != "" && Double(price)! > 0.0 {
                query = query.whereField("eventPrice", isLessThanOrEqualTo: Double(price) ?? 0.0)
            }
        }
        /*if let age = selectedAge, !age.isEmpty {
            //query = query.whereField("age", isEqualTo: age)
        }*/
        if let date = selectedDate {
            let calendar = Calendar.current
            // Get the start of the day (midnight)
            let startOfDay = calendar.startOfDay(for: date)
            // Get the start of the next day (23:59:59.999)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let startTimestamp = Timestamp(date: startOfDay)
            let endTimestamp = Timestamp(date: endOfDay)

            query = query.whereField("eventDateTime", isGreaterThanOrEqualTo: startTimestamp)
                .whereField("eventDateTime", isLessThan: endTimestamp)
        }
        
        // Execute the query
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching data: \(error)")
            } else {
                var results = [[EventModel]]()
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
                    
                    if results.isEmpty {
                        results.append([event])
                    } else {
                        results[0].append(event)
                    }
                }
                self.navigateToResultsPage(results: results)
            }
        }
    }

    // Navigate to Results Page
    func navigateToResultsPage(results: [[EventModel]]) {        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            if let VC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? ViewController {
                VC.filterResualts = results
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
}

// Event Model
struct EventData {
    var title: String
    var category: String
    var location: String
    var price: Double
    var age: String
    var date: String

    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.price = dictionary["price"] as? Double ?? 0.0
        self.age = dictionary["age"] as? String ?? ""
        self.date = dictionary["date"] as? String ?? ""
    }
}
