//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import UIKit

public class CoreFiles {
    
    // Master
    public static func getDataFromFile(title: String, fileURL: URL, withData: @escaping (Data) -> Void) {
        // 1. Start Security Scoping
        guard fileURL.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            print("Unable to access the file.")
            return
        }
        // 2. Create Bookmark
        bookmarkFile(fileUrl: fileURL)
        // 3. Access Bookmarked File
        accessBookmarkedFile { url in
            // 4. Access File Data
            accessDataFromFile(fileUrl: url) { data in
                withData(data)
            }
        }
    }

    public static func accessDataFromFile(fileUrl: URL, dataAccess: @escaping (Data) -> Void) {
        if let data = try? Data(contentsOf: fileUrl) { dataAccess(data) }
    }

    // File Bookmarking
    public static func bookmarkFile(fileUrl: URL, keyName: String = "FileBookmark") {
        // Security Scoping
        do {
            let bookmarkData = try fileUrl.bookmarkData()
            // You can now store this bookmarkData to access the file later
            UserDefaults.standard.set(bookmarkData, forKey: keyName)
        } catch {
            print("Unable to create a bookmark: \(error)")
        }
    }

    public static func accessBookmarkedFile(keyName: String = "FileBookmark", fileAccess: @escaping (URL) -> Void) {
        guard let bookmarkData = UserDefaults.standard.data(forKey: keyName) else {
            print("No bookmark data found")
            return
        }
        var isStale = false
        do {
            let fileURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            let isAccessible = fileURL.startAccessingSecurityScopedResource()
            if isAccessible {
                fileAccess(fileURL)
                fileURL.stopAccessingSecurityScopedResource()
            }
        } catch {
            print("Error resolving bookmark: \(error)")
            return
        }
    }
    
    public static func saveImageToDocuments(image: UIImage, withName filename: String) -> Bool {
           // Ensure the filename has the correct .jpg extension
           let validFilename = filename.hasSuffix(".jpg") ? filename : "\(filename).jpg"
           
           // Obtain the path to the documents directory
           guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
               print("Failed to access documents directory")
               return false
           }
           
           // Create a file path for the image
           let fileURL = documentsDirectory.appendingPathComponent(validFilename)
           
           // Convert the UIImage to JPEG data
           guard let imageData = image.jpegData(compressionQuality: 1.0) else {
               print("Failed to convert UIImage to JPEG")
               return false
           }
           
           // Write the data to the documents directory
           do {
               try imageData.write(to: fileURL)
               print("Image saved successfully to documents directory at: \(fileURL)")
               return true
           } catch {
               print("Error saving image: \(error)")
               return false
           }
       }
    
//    public static func saveImageToDocuments(image: UIImage, withName filename: String) -> Bool {
//        // Obtain the path to the documents directory
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("Failed to access documents directory")
//            return false
//        }
//        
//        // Create a file path for the image
//        let fileURL = documentsDirectory.appendingPathComponent(filename)
//        
//        // Convert the UIImage to JPEG data
//        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//            print("Failed to convert UIImage to JPEG")
//            return false
//        }
//        
//        // Write the data to the documents directory
//        do {
//            try imageData.write(to: fileURL)
//            print("Image saved successfully to documents directory at: \(fileURL)")
//            return true
//        } catch {
//            print("Error saving image: \(error)")
//            return false
//        }
//    }
}


