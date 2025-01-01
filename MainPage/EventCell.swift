import UIKit

class EventCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var locLbl: UILabel!
    @IBOutlet weak var eventLbl: UILabel!
    @IBOutlet weak var locimg: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var timeimg: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var comLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Configure Function
    func configure(with event: EventModel) {
        eventLbl.text = event.title
        comLbl.text = event.company
        descLbl.text = event.description
        locLbl.text = event.location
        
        let dateTime1 = event.dateTime.split(separator: ", ")
        
        timeLbl.text = String(dateTime1[1]) // Convert Substring to String
        dateLbl.text = String(dateTime1[0]) // Convert Substring to String
        
        // Set image from assets
        if let url = URL(string: event.image) {
            loadImage(from: url, into: imageView)
        }
        
        // Styling for borders and shadows
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.masksToBounds = false
        
        // Round image view
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
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

