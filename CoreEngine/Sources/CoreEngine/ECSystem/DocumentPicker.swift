//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/8/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

public struct DocumentPicker: UIViewControllerRepresentable {
    public var allowedContentTypes: [UTType] = [UTType.audio, UTType.image, UTType.video]
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
