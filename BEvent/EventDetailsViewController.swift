import UIKit
import FirebaseFirestore

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    var event: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayEventDetails()
    }

    func displayEventDetails() {
        guard let event = event else { return }
        eventNameLabel.text = event["name"] as? String
        dateLabel.text = event["date"] as? String
        timeLabel.text = event["time"] as? String
        locationLabel.text = event["location"] as? String

        if let imageUrl = event["imageUrl"] as? String {
            // Download and display the image
            loadImage(from: imageUrl)
        }
    }

    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.eventImageView.image = image
                }
            }
        }
    }
}
