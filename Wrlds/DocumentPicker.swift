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

struct DocumentPicker: UIViewControllerRepresentable {
    var allowedContentTypes: [UTType] = [UTType.pdf, UTType.image, UTType.jpeg, UTType.png]
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


struct UploadDocumentView: View {
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
                CoreInputText(label: "Document Title", text: $songTitle, isEdit: .constant(true))
                
                Text("Song Artist: \(url.lastPathComponent)")
                CoreInputText(label: "Document Author", text: $songArtist, isEdit: .constant(true))
                
                if !songTitle.isEmpty {
                    Button("Upload to Firebase") {
                        isLoading = true
                        CoreFirebaseStorage.uploadDocument(title: songTitle, author: songArtist, fileUrl: url) { durl in
                            isLoading = false
                        }
                    }
                }
                
            } else {
                Button("Pick an Document File") {
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
    }
    
    
    
}
