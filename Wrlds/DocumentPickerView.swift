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


struct DocumentPicker: UIViewControllerRepresentable {
    var allowedContentTypes: [UTType] = [UTType.audio]
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
        var parent: DocumentPicker

        init(_ documentPicker: DocumentPicker) {
            self.parent = documentPicker
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}


struct UploadAudioView: View {
    @State private var showDocumentPicker = false
    @State private var pickedURL: URL?
    
    @State var songTitle = ""
    @State var songArtist = ""

    var body: some View {
        VStack {
            if let url = pickedURL {
                Text("Picked file: \(url.lastPathComponent)")
                
                Text("Song Name: \(url.lastPathComponent)")
                TextEditor(text:$songTitle)
                    .frame(height: 25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Text("Song Artist: \(url.lastPathComponent)")
                TextEditor(text:$songArtist)
                    .frame(height: 25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                if !songTitle.isEmpty {
                    Button("Upload to Firebase") {
                        uploadFileToFirebaseStorage(title: songTitle, fileURL: url)
                    }
                }
                
            } else {
                Button("Pick an Audio File") {
                    showDocumentPicker = true
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                self.pickedURL = url
            }
        }
    }
    
    func verifyFileUrl(fileUrl: URL) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: fileUrl.path) && fileManager.isReadableFile(atPath: fileUrl.path)
    }
    
    func uploadFileToFirebaseStorage(title: String, fileURL: URL) {
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            print("Unable to access the file.")
            return
        }
        
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"
        let fileCoordinator = NSFileCoordinator()
        var error: NSError?

        // Create a bookmark to persist access
        do {
            let bookmarkData = try fileURL.bookmarkData()
            // You can now store this bookmarkData to access the file later
            UserDefaults.standard.set(bookmarkData, forKey: "FileBookmark")
        } catch {
            print("Unable to create a bookmark: \(error)")
        }
        
        let storageRef = Storage.storage().reference().child("songs/\(title)")
        
        if let fileURL = accessBookmarkedFile() {
            // Upload the file to Firebase
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
