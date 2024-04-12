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
    
    public static func uploadSong(title: String, artist: String, fileUrl: URL, onSuccess: @escaping (String) -> Void) {
        CoreFiles.getDataFromFile(title: title, fileURL: fileUrl, withData: { data in
            let meta = CoreFirebaseStorage.songsMetadata(title: title)
            CoreFirebaseStorage.uploadFile(storage: CoreFirebaseStorage.songs(title: title), data: data, meta: meta, onSuccess: { downloadUrl in
                    onSuccess(downloadUrl)
                    CoreFirebaseStorage.saveMedia(title: title, artist: artist, downloadURL: downloadUrl)
            })
        })
    }
    
    public static func uploadFile(storage: StorageReference, data: Data, meta: StorageMetadata, onSuccess: @escaping (String) -> Void) {
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
    
    public static func saveMedia(title: String, artist: String, downloadURL: String) {
        // Create a new Song object
        let newSong = Media()
        newSong.title = title // Example title
        newSong.artist = "Unknown Artist" // Placeholder artist
        newSong.downloadUrl = downloadURL
        
        newRealm().safeWrite { r in
            r.create(Media.self, value: newSong, update: .all)
            r.refresh()
        }

        // Save the Song object and write to Firebase Realtime Database
//        firebaseDatabaseSET(obj: newSong) { db in
//            db.child("songs").child(newSong.id)
//        }
    }
}
