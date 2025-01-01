//
//  AppData.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import FirebaseAuth

class AppData {
    static var admin: [User] = [User(username: "beventadmin@gmail.com", password: "IamAdmin234", userType: .admin)]
    static var organizers: [Organizer] = []
    // with sample data
    static var attendees: [Attendee] = []
    
    
    static var loggedInUser: User?
    //loggedInUser = Auth.auth().currentUser!.uid
    
    
    
    static func wipe() {
        admin = []
        attendees = []
    }
    
    // Methods to manage users
    
    static func getUser(username: String) -> User? {
        let allUsers: [User] = admin + attendees + organizers
        return allUsers.first(where: { $0.username == username })
    }
    static func getUser(uuid: UUID) -> User? {
        let allUsers: [User] = admin + attendees + organizers
        return allUsers.first(where: { $0.uuid == uuid })
    }
    
    
    static func addUser(user: User) {
        if user is Attendee {
            attendees.append(user as! Attendee)
        } else if user is Organizer {
            organizers.append(user as! Organizer)
        } else {
            admin.append(user)
        }
        saveData()
    }
    
    static func editUser(user: User) {
        if user is Attendee {
            if let userIndex = attendees.firstIndex(of: user as! Attendee) {
                attendees.remove(at: userIndex)
                attendees.insert(user as! Attendee, at: userIndex)
                saveData()
            }
        } else if user is Organizer {
            if let userIndex = organizers.firstIndex(of: user as! Organizer) {
                organizers.remove(at: userIndex)
                organizers.insert(user as! Organizer, at: userIndex)
                saveData()
            }
        } else {
            if let userIndex = admin.firstIndex(of: user) {
                admin.remove(at: userIndex)
                admin.insert(user, at: userIndex)
                saveData()
            }
        }
    }
    // return user if email exists, used for registering a new user
    static func getUserFromEmail(email: String) -> User? {
        let allUsers: [User] = AppData.admin + AppData.organizers + AppData.attendees
        let matchingUsers: [User] = allUsers.filter{ $0.username == email }
        if (matchingUsers.count > 0) {
            return matchingUsers[0]
        }
        return nil
    }
    
    
    static func deleteUser(user: User) -> Bool {
        if user is Attendee {
            if let userIndex = attendees.firstIndex(of: user as! Attendee) {
                attendees.remove(at: userIndex)
                saveData()
                return true
            }
        } else if user is Organizer {
            if let userIndex = organizers.firstIndex(of: user as! Organizer) {
                organizers.remove(at: userIndex)
                saveData()
                return true
            }
        }
        
        return false
    }
    
    static func loadSampleData() {
        // ensure that no data is already present
        guard attendees.isEmpty else { return }

        attendees = [attendee1, attendee2]
    }
    static var attendee1 = Attendee(firstName: "Sara",
                                    lastName: "Khalaf",
                                    mobileNum: "05012345",
                                    gender: Gender.female,
                                    dateOfBirth: DateComponents(calendar: Calendar.current, year: 1995, month: 6, day: 15),
                                    username: "sara.khalaf@email.com",
                                    password: "password123")

    static var attendee2 = Attendee(firstName: "Ahmed",
                                    lastName: "Mohd",
                                    mobileNum: "05098765",
                                    gender: Gender.male,
                                    dateOfBirth: DateComponents(calendar: Calendar.current, year: 1992, month: 11, day: 22),
                                    username: "ahmed.mohd@email.com",
                                    password: "mypassword456")
    
}
