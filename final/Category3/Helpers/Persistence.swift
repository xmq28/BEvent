//
//  Persistence.swift
//  final
//
//  Created by Sara Khalaf on 05/12/2024.
//

import Foundation

extension AppData {
    
    fileprivate enum FileName: String {
        case admins, attendees, organizers
    }
    
    // get the URL for data storage
    fileprivate static func archiveURL(_ fileName: FileName) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName.rawValue).appendingPathExtension("plist")
    }
    
    // use this function to save data after any data manipulation happens
    static func saveData() {
        saveUsers(toFile: .admins)
        saveUsers(toFile: .attendees)
        saveUsers(toFile: .organizers)
    }
    
    // loadData will wipe all AppData arrays to prevent duplication, make sure to call it only once at app startup
    static func loadData() {
        AppData.wipe()
        loadUsers(fromFile: .admins)
        loadUsers(fromFile: .attendees)
        loadUsers(fromFile: .organizers)
    }
    
    fileprivate static func saveUsers(toFile: FileName) {
        let archiveURL = archiveURL(toFile)
        let propertyListEncoder = PropertyListEncoder()
        do {
            if toFile == .attendees {
                guard attendees.count > 0 else {return}
                let encodedData = try propertyListEncoder.encode(attendees)
                try encodedData.write(to: archiveURL, options: .noFileProtection)
            } else if toFile == .organizers {
                guard organizers.count > 0 else {return}
                let encodedData = try propertyListEncoder.encode(organizers)
                try encodedData.write(to: archiveURL, options: .noFileProtection)
            } else if toFile == .admins {
                guard admin.count > 0 else {return}
                let encodedData = try propertyListEncoder.encode(admin)
                try encodedData.write(to: archiveURL, options: .noFileProtection)
            }
        } catch EncodingError.invalidValue {
            print("could not encode users")
        } catch {
            print("could not write users")
        }
    }
    
    
    fileprivate static func loadUsers(fromFile: FileName) {
        let archiveURL = archiveURL(fromFile)
        let propertyListDecoder = PropertyListDecoder()
        guard let retrievedData = try? Data(contentsOf: archiveURL) else {
            print("No user data found")
            return
        }
        do {
            if fromFile == .attendees {
                var decodedData: [Attendee] = []
                decodedData = try propertyListDecoder.decode([Attendee].self, from: retrievedData)
                attendees.append(contentsOf: decodedData)
            } else if fromFile == .organizers {
                var decodedData: [Organizer] = []
                decodedData = try propertyListDecoder.decode([Organizer].self, from: retrievedData)
                organizers.append(contentsOf: decodedData)
            } else if fromFile == .admins {
                var decodedData: [User] = []
                decodedData = try propertyListDecoder.decode([User].self, from: retrievedData)
                admin.append(contentsOf: decodedData)
            }
        } catch {
            print("could not load data: \(error)")
        }
    }
}
