import UIKit
import FirebaseFirestore

class ViewFeedbacksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedbackTableView: UITableView!
    var db = Firestore.firestore()
    var feedbackList: [[String: Any]] = [] // تخزين الملاحظات من Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // إعداد TableView
        feedbackTableView.delegate = self
        feedbackTableView.dataSource = self
        
        // تسجيل الخلية
        feedbackTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeedbackCell")
        
        // تحميل البيانات من Firebase
        fetchFeedbackFromFirestore()
    }
    
    // جلب الملاحظات من Firestore
    func fetchFeedbackFromFirestore() {
        db.collection("feedback").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching feedback: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                self.feedbackList = snapshot.documents.map { $0.data() }
                DispatchQueue.main.async {
                    self.feedbackTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath)
        let feedback = feedbackList[indexPath.row]
        
        // Retrieve message and rating
        let message = feedback["message"] as? String ?? "No Feedback"
        let rating = feedback["rating"] as? Int ?? 0 // Assuming the rating is stored as an integer

        // Display message and rating, for example: "Feedback: message | Rating: rating"
        cell.textLabel?.text = "\(message) | Rating: \(rating)"
        
        return cell
    }
}
