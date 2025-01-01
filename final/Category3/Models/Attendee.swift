//
//  Attendee.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.
//


import Foundation

class Attendee: User {
    var firstName: String
    var lastName: String
    var name: String {
        return "\(firstName) \(lastName)"
    }
    var mobileNum: String
    var gender: Gender
    var dateOfBirth: DateComponents // use 'year', 'month', and 'day' components
    
    override var description: String {
        return """
                -- Attendee --
                \(super.description)
                - Attendee Info -
                Name: \(name)
                Gender: \(gender.rawValue)
                Mobile Number: \(mobileNum)
                Age: \(age)
                """
    }

    var age: Int {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Check if the 'dateOfBirth' components are valid
        guard let dobYear = dateOfBirth.year,
              let dobMonth = dateOfBirth.month,
              let dobDay = dateOfBirth.day else {
            return 0 // Return 0 if dateOfBirth components are not valid
        }
        
        // Create a birthdate from the 'dateOfBirth' components
        if let birthDate = calendar.date(from: DateComponents(year: dobYear, month: dobMonth, day: dobDay)) {
            // Calculate the difference in years between the birthdate and the current date
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
            return ageComponents.year ?? 0
        } else {
            return 0 // Return 0 if the birthdate couldn't be created
        }
    } // calculated get-only property
    
    enum CodingKeys: Codable, CodingKey {
        case firstName, lastName, mobileNum, gender, dateOfBirth
    }
    
    init(firstName: String, lastName: String, mobileNum: String, gender: Gender, dateOfBirth: DateComponents, username: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNum = mobileNum
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        super.init(username: username, password: password, userType: .attendee)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(mobileNum, forKey: .mobileNum)
        try container.encode(gender, forKey: .gender)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try super.encode(to: encoder)
    }
    
    // This initializer decodes the object and is required for coding functionality
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try values.decodeIfPresent(String.self, forKey: .firstName)!
        self.lastName = try values.decodeIfPresent(String.self, forKey: .lastName)!
        self.mobileNum = try values.decodeIfPresent(String.self, forKey: .mobileNum)!
        self.gender = try values.decodeIfPresent(Gender.self, forKey: .gender)!
        self.dateOfBirth = try values.decodeIfPresent(DateComponents.self, forKey: .dateOfBirth)!
        // Decode base class
        try super.init(from: decoder)
    }
}