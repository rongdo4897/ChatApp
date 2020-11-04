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
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
    public func insertUser(with user:ChatAppUser, completion: @escaping (Bool) -> Void) {
        let data = ["firstName" : user.firstName ,
                    "lastName" : user.lastName
        ]
        database.child(user.safeEmail).setValue(data) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            
            /*
             users => [
                [
                    "name":
                    "safe_email":
                ],
                [
                    "name":
                    "safe_email":
                ]
             ]
             */
            
            
            // list users
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // if listUser != nil -> append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName ,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                    
                } else {
                    // if listUser == nil -> create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName ,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
            
            completion(true)
        }
    }
    
    /// - get All list User Firebase
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

//MARK: - Model User
struct ChatAppUser {
    let firstName:String
    let lastName:String
    let emailAddress:String
    var safeEmail:String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName:String {
        return "\(safeEmail)_profile_picture.png"
    }
}

//MARK: - Database error enum
enum DatabaseError: Error {
    case failedToFetch
}
