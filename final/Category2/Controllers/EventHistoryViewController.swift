//
//  EventHistoryViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit

class EventHistoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    

    @IBOutlet weak var tableView: UITableView!
    var eventListing = [EventModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventListing = loadeventsFromUserDefaults()
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    @IBAction func actionFeedback(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadeventsFromUserDefaults() -> [EventModel] {
        if let data = UserDefaults.standard.data(forKey: "eventsHistory") {
            let decoder = JSONDecoder()
            
            do {
                let events = try decoder.decode([EventModel].self, from: data)
                return events
            } catch {
                print("Failed to decode people array: \(error)")
                return []
            }
        }
        return []
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
        vc.isFromHistory = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
