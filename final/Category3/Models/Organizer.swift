//
//  Organizer.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.
//

import Foundation
import UIKit

class Organizer: User {
    var name: String
    var phone: String
    
    override var description: String {
        return """
                -- Organizer --
                \(super.description)
                - Organizer Info -
                Name: \(name)
                Phone Number: \(phone)
                """
    }
    
    enum CodingKeys: Codable, CodingKey {
        case name, phone
    }
    
    init(name: String, phone: String, username: String, password: String) {
        self.name = name
        self.phone = phone
        super.init(username: username, password: password, userType: .organizer)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try super.encode(to: encoder)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.phone = try values.decode(String.self, forKey: .phone)
        try super.init(from: decoder)
    }
    
    static func < (lhs: Organizer, rhs: Organizer) -> Bool {
        return (lhs.name < rhs.name)
    }
}
