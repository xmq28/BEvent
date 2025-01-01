//
//  SettingsTableViewController.swift
//  final
//
//  Created by Sara Khalaf on 05/12/2024.
//


import UIKit
import FirebaseAuth // Make sure to import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    var attendeeLog: Attendee?
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var eventPreferenceLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!

    @IBAction func logoutButton(_ sender: Any) {
        logoutAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Get the logged-in user's email
        guard let email = Auth.auth().currentUser?.email else {
            return 6 // Default to showing all cells if no user is logged in
        }

        // Check the email for specific conditions
        if email.contains("@bevent.admin") {
            return 3 // Hide the last 3 cells
        } else if email.contains("@bevent.organizer") {
            return 5 // Hide the last cell
        }
        return 6 // Show all cells for other users
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row after tapping
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // For the navigation bar to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
