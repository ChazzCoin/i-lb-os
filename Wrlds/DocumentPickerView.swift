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
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Text("Song Artist: \(url.lastPathComponent)")
                TextEditor(text:$songArtist)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button("Upload to Firebase") {
                    uploadAudioToFirebase(url)
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

    func uploadAudioToFirebase(_ url: URL) {
    
        
        let meta = StorageMetadata()
        meta.contentType = "audio/m4a"

        do {
            
            let fileCoordinator = NSFileCoordinator()
            var error: NSError?
            
            if let bookmark = createBookmark(from: url) {
                
                if let bm = UserDefaults.standard.object(forKey: "myFileBookmark") as? URL {
                    fileCoordinator.coordinate(readingItemAt: bm, options: [], error: &error) { (url) in
                        let isAccessible = url.startAccessingSecurityScopedResource()
        //                let temp = verifyFileUrl(fileUrl: url)
                        print(isAccessible)
                        if isAccessible {
                            // Now you can check with FileManager or proceed with uploading the file
                            // Upload file to Firebase
                            let storageRef = Storage.storage().reference().child("songs/\(url.lastPathComponent)")
                            // Start the file upload
                            storageRef.putFile(from: url, metadata: meta) { data, error in
                                // Don't forget to stop accessing the resource
                                url.stopAccessingSecurityScopedResource()
                                guard data != nil else {
                                    // Handle error
                                    print("Error during upload: \(error?.localizedDescription ?? "Unknown error")")
                                    return
                                }
                                
                                // File uploaded successfully, now get the download URL
                                storageRef.downloadURL { (downloadURL, error) in
                                    guard let downloadURL = downloadURL else {
                                        // Handle error
                                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                                        return
                                    }

                                    // Create a new Song object
                                    let newSong = Song()
                                    newSong.title = url.deletingPathExtension().lastPathComponent // Example title
                                    newSong.artist = "Unknown Artist" // Placeholder artist
                                    newSong.downloadUrl = downloadURL.absoluteString

                                    // Save the Song object and write to Firebase Realtime Database
                                    firebaseDatabaseSET(obj: newSong) { db in
                                        db.child("songs").child(newSong.id)
                                    }
                                }
                            }
                            
                            
                            
                        } else {
                            // Handle the error or the fact the file isn't accessible
                            print("File Not Accessable")
                        }
                    }

                    if let error = error {
                        // Handle any errors here
                        print("File Error: \(error)")
                    }
                }
                
                
               
                
            }
            
//            let temp = UserDefaults.standard.object(forKey: "myFileBookmark")

            
            
            
            
        } catch {
            print("Error while uploading")
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
