//
//  ImageUploader.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import Firebase
import FirebaseStorage

enum ImageUploadError: Error {
    case uploadFailed
}

struct ImageUploader {
    func uploadImage(imageData: Data) async throws -> String {
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
