//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 10/29/20.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

}

//MARK: - Account Managerment
extension DatabaseManager {
    
    public func checkUserExists(with email:String ,
                                completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard let _ = snapshot.value as? String else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// - insert new User to database
    public func insertUser(with user:ChatAppUser) {
        let data = ["firstName" : user.firstName ,
                    "lastName" : user.lastName
        ]
        
        database.child(user.safeEmail).setValue(data)
    }
}

struct ChatAppUser {
    let firstName:String
    let lastName:String
    let emailAddress:String
    //    let profilePictureURL:String
    var safeEmail:String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
