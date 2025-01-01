//
//  EventRegisterConfimrationViewController.swift
//  final
//
//  Created by MacBookPro on 31/12/2024.
//

import UIKit
import Kingfisher

class EventRegisterConfimrationViewController: UIViewController {
    
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var locationPrice: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var event = EventModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()

        // Do any additional setup after loading the view.
    }
    
    func configureView(){
        self.lblName.text = event.name
        self.lblLocation.text = event.location
        self.lblDescription.text = event.desciptions
        self.locationPrice.text = "\(event.price)"
        if let imageUrl = URL(string: event.image){
            self.imgEvent.kf.setImage(with: imageUrl)
        }
    }
    
    @IBAction func actionRegister(_ sender: Any) {
        var registerdEvents = self.loadeventsFromUserDefaults()
        registerdEvents.append(self.event)
        self.saveEventsToUserDefaults(events: registerdEvents)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventRegisterConfimedViewController") as! EventRegisterConfimedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

