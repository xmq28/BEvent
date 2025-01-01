//
//  confirmationScreen3.swift
//  BEvent-recent
//
//  Created by guest_ on 28/12/2024.
//

import UIKit

class confirmationScreen3: UIViewController {
    
    // Add a property to receive the event title or ID
        var eventTitle: String?

        override func viewDidLoad() {
            super.viewDidLoad()

            // You can use this eventTitle here as needed
            if let title = eventTitle {
                print("Event Title: \(title)")
            }
        }
    }
    


    


