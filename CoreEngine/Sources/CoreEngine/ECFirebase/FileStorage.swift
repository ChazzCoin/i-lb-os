//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import FirebaseStorage


public class CoreFirebaseStorage {
    
    public static let storageRef = Storage.storage().reference()
    public static func songs(title: String) -> StorageReference { return storageRef.child("songs/\(title)") }
    public static func images(title: String) -> StorageReference { return storageRef.child("images/\(title)") }
    public static func videos(title: String) -> StorageReference { return storageRef.child("videos/\(title)") }
    public static func documents(title: String) -> StorageReference { return storageRef.child("documents/\(title)") }
    
    public static func songsMetadata(title: String) -> StorageMetadata {
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"
        return meta
    }
    public static func imagesMetadata(title: String) -> StorageMetadata {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg" // PNG: image/png
        return meta
    }
    public static func videosMetadata(title: String) -> StorageMetadata {
        let meta = StorageMetadata()
        meta.contentType = "video/mp4"
        return meta
    }
    
    func uploadFile(storage: StorageReference, data: Data, meta: StorageMetadata, onSuccess: @escaping (String) -> Void) {
        storage.putData(data, metadata: meta) { metadata, error in
            if let error = error {
                // Handle any errors
                print("Error uploading file: \(error)")
            } else {
                print("Upload successful, metadata: \(String(describing: metadata))")
                // File uploaded successfully, now get the download URL
                storage.downloadURL { (downloadURL, error) in
                    guard let downloadURL = downloadURL else {
                        // Handle error
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    onSuccess(downloadURL.absoluteString)
                }
            }
        }
    }
}
