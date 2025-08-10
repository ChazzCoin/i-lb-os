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


public struct DocumentPicker: UIViewControllerRepresentable {
    public var allowedContentTypes: [UTType] = [UTType.pdf, UTType.image, UTType.jpeg, UTType.png]
    public var onPick: (URL) -> Void

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        public var parent: DocumentPicker

        public init(_ documentPicker: DocumentPicker) {
            self.parent = documentPicker
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}


public struct UploadDocumentView: View {
    @State public var showDocumentPicker = false
    @State public var isLoading = false
    @State public var pickedURL: URL?


    @State public var songTitle = ""
    @State public var songArtist = ""
    @State public var uploadStatus: String = ""
    
    public var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(gradient: Gradient(colors: [Color(.systemBlue).opacity(0.12), Color(.systemIndigo).opacity(0.09)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Title
                HStack {
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.accentColor)
                    Text("Upload Document")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // Picked file info & form
                if let url = pickedURL {
                    VStack(spacing: 20) {
                        // File Card
                        HStack(spacing: 16) {
                            Image(systemName: "doc.text.fill")
                                .resizable()
                                .frame(width: 36, height: 44)
                                .foregroundColor(.blue)
                                .shadow(radius: 1, y: 2)
                            VStack(alignment: .leading) {
                                Text(url.lastPathComponent)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text(url.pathExtension.uppercased())
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.96))
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
                        )

                        // Document info form
                        VStack(spacing: 16) {
                            CoreInputText(label: "Document Title", text: $songTitle, isEdit: .constant(true))
                                .accentColor(.indigo)
                            CoreInputText(label: "Document Author", text: $songArtist, isEdit: .constant(true))
                                .accentColor(.indigo)
                        }
                        .padding(.horizontal, 2)

                        // Upload Button
                        Button(action: {
                            isLoading = true
                            uploadStatus = ""
                            CoreFirebaseStorage.uploadDocument(title: songTitle, author: songArtist, fileUrl: url) { durl in
                                isLoading = false
                                uploadStatus = durl != nil ? "Upload complete!" : "Upload failed."
                                // Optionally, reset pickedURL/songTitle/songArtist here
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                                Text(isLoading ? "Uploading..." : "Upload")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((isLoading || songTitle.isEmpty) ? Color.gray.opacity(0.5) : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 2, y: 2)
                        }
                        .disabled(songTitle.isEmpty || isLoading)

                        if !uploadStatus.isEmpty {
                            Text(uploadStatus)
                                .font(.callout)
                                .foregroundColor(uploadStatus.contains("complete") ? .green : .red)
                                .padding(.top, 6)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal)
                }
                
                Spacer()

                // Pick another file
                if pickedURL != nil && !isLoading {
                    Button {
                        showDocumentPicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.app")
                            Text("Pick Another Document")
                        }
                        .font(.callout)
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 460)
        }
        .sheet(isPresented: $showDocumentPicker, onDismiss: {
            // Optionally: reset fields
        }) {
            DocumentPicker { url in
                self.pickedURL = url
                self.songTitle = ""
                self.songArtist = ""
                self.uploadStatus = ""
            }
        }
        .onAppear {
            if pickedURL == nil {
                showDocumentPicker = true
            }
        }
        .isLoading(showLoading: $isLoading)
        .animation(.easeInOut, value: pickedURL)
    }
}
