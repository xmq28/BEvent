//
//  User.swift
//  final
//
//  Created by Sara Khalaf on 04/12/2024.
//

import Foundation

class User: Codable, Equatable, Comparable, CustomStringConvertible {
    
    var username: String
    var password: String
    var uuid: UUID
    var userType: UserType
    
    var description: String {
        return """
                - User Info -
                ID: \(uuid)
                Username: \(username)
                """
    }
    
//    enum CodingKeys: Codable, CodingKey {
//        case username, password, id, userType
//    }
    
    init(username: String, password: String, userType: UserType) {
        self.username = username
        self.password = password
        self.uuid = UUID()
        self.userType = userType
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return (lhs.username == rhs.username)
    }
    static func < (lhs: User, rhs: User) -> Bool {
        return (lhs.username < rhs.username)
    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(username, forKey: .username)
//        try container.encode(password, forKey: .password)
//        try container.encode(id, forKey: .id)
//        try container.encode(userType, forKey: .userType)
//    }
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.username = try container.decode(String.self, forKey: .username)
//        self.password = try container.decode(String.self, forKey: .password)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        self.userType = try container.decode(UserType.self, forKey: .userType)
//    }
    
}
