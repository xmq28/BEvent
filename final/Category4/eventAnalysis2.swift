import UIKit
import FirebaseFirestore

class eventAnalysis2: UIViewController {

    var selectedEventTitle: String?  // To store the passed event title
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Debugging: Print selectedEventTitle to check if it's passed correctly
        print(" \(selectedEventTitle ?? "None")")
        
        // Display the event title in the label if it's passed
        if let eventTitle = selectedEventTitle {
            eventTitleLabel.text = " \(eventTitle)"
        } else {
            eventTitleLabel.text = "No event title selected"
        }
    }
}
