//
//  StorageManager.swift
//  ChatApp
//
//  Created by Hoang Tung Lam on 11/2/20.
//

import Foundation
import FirebaseStorage

enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    static let share = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /// - Value return Result
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// - upload picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        // upload data
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            // get link download data
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url , error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
}
