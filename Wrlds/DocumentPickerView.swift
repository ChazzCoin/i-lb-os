//
//  DocumentPickerView.swift
//  Wrlds
//
//  Created by Charles Romeo on 1/10/24.
//

import Foundation
import SwiftUI
import FirebaseStorage
import UniformTypeIdentifiers
import AVFoundation
import CoreEngine

struct DocumentPickerLocal: UIViewControllerRepresentable {
    var allowedContentTypes: [UTType] = [UTType.audio, UTType.video]
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerLocal

        init(_ documentPicker: DocumentPickerLocal) {
            self.parent = documentPicker
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}


struct UploadAudioView: View {
    @State public var showDocumentPicker = false
    @State public var isLoading = false
    @State public var pickedURL: URL?
    
    @State var songTitle = ""
    @State var songArtist = ""

    var body: some View {
        VStack {
            if let url = pickedURL {
                Text("Picked file: \(url.lastPathComponent)")
                
                Text("Song Name: \(url.lastPathComponent)")
                CoreInputText(label: "Song Title", text: $songTitle, isEdit: .constant(true))
                
                Text("Song Artist: \(url.lastPathComponent)")
                CoreInputText(label: "Song Artist", text: $songArtist, isEdit: .constant(true))
                
                if !songTitle.isEmpty {
                    Button("Upload to Firebase") {
                        isLoading = true
                        CoreFirebaseStorage.uploadSong(title: songTitle, artist: songArtist, fileUrl: url) { durl in
                            isLoading = false
                        }
//                        uploadFileToFirebaseStorage(title: songTitle, fileURL: url)
//                        isLoading = false
                    }
                }
                
            } else {
                Button("Pick an Audio File") {
                    showDocumentPicker = true
                }
            }
        }
        .isLoading(showLoading: $isLoading)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerLocal { url in
                self.pickedURL = url
            }
        }
//        .onAppear() {
//            isLoading = true
//        }
    }
    

    
    func uploadFileToFirebaseStorage(title: String, fileURL: URL) {
        // Security Scoping
        guard fileURL.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            print("Unable to access the file.")
            return
        }
        
        // MetaData
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"
        let storageRef = Storage.storage().reference().child("songs/\(title)")
        
        
        // Security Scoping
        do {
            let bookmarkData = try fileURL.bookmarkData()
            // You can now store this bookmarkData to access the file later
            UserDefaults.standard.set(bookmarkData, forKey: "FileBookmark")
        } catch {
            print("Unable to create a bookmark: \(error)")
        }
        
        
        
        
        
        if let fileURL = accessBookmarkedFile() {
            
            // Security Scoping
            let isAccessible = fileURL.startAccessingSecurityScopedResource()
            
            if let temp = try? Data(contentsOf: fileURL) {
                print("File is accessible: \(isAccessible)")
                
                if isAccessible {
                    
                    
                    // Upload the file
                    storageRef.putData(temp, metadata: meta) { metadata, error in
    //                    fileURL.stopAccessingSecurityScopedResource()
                        if let error = error {
                            // Handle any errors
                            print("Error uploading file: \(error)")
                            fileURL.stopAccessingSecurityScopedResource()
                        } else {
                            // Metadata contains file metadata such as size, content-type, etc.
                            print("Upload successful, metadata: \(String(describing: metadata))")
                            // File uploaded successfully, now get the download URL
                            storageRef.downloadURL { (downloadURL, error) in
                                guard let downloadURL = downloadURL else {
                                    // Handle error
                                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                                    return
                                }

                                // Create a new Song object
                                let newSong = Song()
                                newSong.title = title // Example title
                                newSong.artist = "Unknown Artist" // Placeholder artist
                                newSong.downloadUrl = downloadURL.absoluteString

                                // Save the Song object and write to Firebase Realtime Database
                                firebaseDatabaseSET(obj: newSong) { db in
                                    db.child("songs").child(newSong.id)
                                }
                                fileURL.stopAccessingSecurityScopedResource()
                            }
                        }
                    }
                }
            }
            
            
        } else {
            print("Failed to retrieve file from bookmark")
        }
        
        
    }
    
    func accessBookmarkedFile() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "FileBookmark") else {
            print("No bookmark data found")
            return nil
        }
        var isStale = false
        do {
            let fileURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            return fileURL
        } catch {
            print("Error resolving bookmark: \(error)")
            return nil
        }
    }

    
    func extractMetadata(from audioURL: URL) -> (title: String?, artist: String?, albumName: String?) {
        let asset = AVAsset(url: audioURL)
        let metadata = asset.metadata

        var title: String?
        var artist: String?
        var albumName: String?

        for item in metadata {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }

            switch key {
            case "title":
                title = value as? String
            case "artist":
                artist = value as? String
            case "albumName":
                albumName = value as? String
            default:
                break
            }
        }

        return (title, artist, albumName)
    }

    func createBookmark(from url: URL) -> Data? {
        do {
            let bookmark = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmark, forKey: "myFileBookmark")
            return bookmark
        } catch {
            print("Error creating bookmark: \(error)")
            return nil
        }
    }
    
    func resolveBookmark(bookmarkData: Data) -> URL? {
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            return url
        } catch {
            print("Error resolving bookmark: \(error)")
            return nil
        }
    }



}
