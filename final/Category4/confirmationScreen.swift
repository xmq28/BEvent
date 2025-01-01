import UIKit

class ConfirmationScreen: UIViewController {
    
    var event: Event?  // This will store the passed event data
    
    // Outlets for the UI elements (labels, etc.)
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display the event data if available
        if let event = event {
            eventTitleLabel.text = event.title
            eventDescriptionLabel.text = event.description
            eventDateLabel.text = formatDate(event.eventDateTime)
            eventLocationLabel.text = event.location
        }
    }
    
    // Helper function to format the event date
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
