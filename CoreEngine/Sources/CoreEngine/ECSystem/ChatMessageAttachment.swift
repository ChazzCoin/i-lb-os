//
//  ChatMessageAttachment.swift
//  CoreEngine
//
//  Created by Charles Romeo on 7/15/25.
//

import SwiftUI

public struct UploadChatAttachment: View {
    @State public var showDocumentPicker = false
    @State public var isLoading = false
    @State public var pickedURL: URL?
    public var onAttach: ((URL) -> Void)? = nil

    @State public var title = ""
    @State public var author = ""
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

                        // Upload Button
                        Button(action: {
                            onAttach?(url)
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                                Text("Attach")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((isLoading || title.isEmpty) ? Color.gray.opacity(0.5) : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 2, y: 2)
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
                self.title = ""
                self.author = ""
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
