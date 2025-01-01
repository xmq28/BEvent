//
//  EventListingViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit
import FirebaseFirestore
import Kingfisher


struct EventModel : Codable{
    var id : String = ""
    var image : String = ""
    var name : String = ""
    var dateStr : String = ""
    var location : String = ""
    var desciptions : String = ""
    var price : Double  = 0.0
}


class EventListingViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
  
    
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var eventListing = [EventModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nil
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchEventData()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionMyEvents(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventHistoryViewController") as! EventHistoryViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchEventData() {
        self.eventListing = []
        db.collection("createEvent").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return } // Safe reference to self
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                print("No events found.")
                return
            }

            // Loop through the documents and create containers for each event
            // Reversed order to display new events on top
            for document in snapshot.documents.reversed() {
                var event = EventModel()
                event.id = document.documentID
                event.name = document["eventTitle"] as? String ?? "No Title"
                event.image = document["eventImages"] as? String ?? ""
                event.location = document["eventLocation"] as? String ?? ""
                event.price = document["eventPrice"] as? Double ?? 0.0
                event.desciptions = document["eventDescription"] as? String ?? ""
                if let date = document["eventDateTime"] as? Timestamp{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
                    event.dateStr = dateFormatter.string(from: date.dateValue())
                }
                self.eventListing.append(event)
            }
            self.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListDetailsTableViewCell", for: indexPath) as! EventListDetailsTableViewCell
        cell.lblName.text = self.eventListing[indexPath.row].name
        cell.lblTime.text = self.eventListing[indexPath.row].dateStr
        cell.selectionStyle = .none
        if let imageUrl = URL(string: self.eventListing[indexPath.row].image){
            cell.imgEvent.kf.setImage(with: imageUrl)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailssViewController") as! EventDetailssViewController
        vc.event = self.eventListing[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
