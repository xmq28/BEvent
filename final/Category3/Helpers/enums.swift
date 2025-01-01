//
//  enums.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.
//

import Foundation

enum Gender: String, Codable {
    case male = "Male", female = "Female"
}

enum UserType: Codable {
    case attendee, organizer, admin
}
