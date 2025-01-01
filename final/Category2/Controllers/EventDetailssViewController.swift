//
//  EventDetailsViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit
import Kingfisher

class EventDetailssViewController: UIViewController {
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblEventTime: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var imgEvent: UIImageView!
    
    @IBOutlet weak var btnRegister: UIButton!
    var event = EventModel()
    var isFromHistory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = ""
        self.configureView()

        // Do any additional setup after loading the view.
    }
    
    func configureView(){
        self.eventName.text = event.name
        let dateandTime = event.dateStr.components(separatedBy: " ")
        self.lblEventTime.text = dateandTime[1]
        self.lblEventDate.text = dateandTime[0]
        self.lblLocation.text = event.location
        if let imageUrl = URL(string: event.image){
            self.imgEvent.kf.setImage(with: imageUrl)
        }
        
        if isFromHistory{
            self.btnRegister.setTitle("Cancel Registration", for: .normal)
        }
    }
    
    @IBAction func actionRegister(_ sender: Any) {
        if isFromHistory{
            var registerdEvents = self.loadeventsFromUserDefaults()
            registerdEvents.removeAll(where: {$0.id == self.event.id})
            self.saveEventsToUserDefaults(events: registerdEvents)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventHistoryRemovedViewController") as! EventHistoryRemovedViewController
            self.navigationController?.pushViewController(vc, animated: true)
           
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventRegisterConfimrationViewController") as! EventRegisterConfimrationViewController
            vc.event = self.event
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveEventsToUserDefaults(events: [EventModel]) {
        let encoder = JSONEncoder()
        
        do {
            // Encode the array of events into Data
            let data = try encoder.encode(events)
            
            // Store the encoded Data in UserDefaults
            UserDefaults.standard.set(data, forKey: "eventsHistory")
        } catch {
            print("Failed to encode events array: \(error)")
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
