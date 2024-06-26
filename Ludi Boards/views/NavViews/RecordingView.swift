//
//  RecordingView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import SwiftUI
import RealmSwift
import CoreEngine

struct RecordingListView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    
    var body: some View {
        NavigationStack {
            SearchableRecordingsListView(isShowing: self.$isShowing)
                .environmentObject(self.BEO)
        }
        .navigationTitle("Current Activity Recordings")
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
}


struct RecordingView: View {
    @State var recordingId: String
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    @Environment(\.presentationMode) var presentationMode
    
    @State var name: String = ""
    @State var details: String = ""
    @State var boardId: String = ""
    @State var dateCreated: String = ""
    @State var duration: Double = 0.0

    var body: some View {
        Form {
//            
//            DStack {
//                CoreConfirmButton(
//                    title: "Save",
//                    message: "Are you sure you want to save this Recording?",
//                    action: {
//                        self.BEO.realmInstance.safeFindByField(Recording.self, value: self.recordingId) { obj in
//                            self.BEO.realmInstance.safeWrite { _ in
//                                obj.name = name
//                                obj.details = details
//                                obj.dateCreated = dateCreated
//                            }
//                        }
//                    },
//                    isEnabled: true
//                )
//                
//                CoreConfirmButton(
//                    title: "Delete",
//                    message: "Are you sure you want to delete this Recording?",
//                    action: {
//                        self.BEO.realmInstance.safeFindByField(Recording.self, value: self.recordingId) { obj in
//                            self.BEO.realmInstance.safeWrite { r in
//                                r.delete(obj)
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                        }
//                    },
//                    isEnabled: true
//                )
//                
//                CoreConfirmButton(
//                    title: "Load and Play",
//                    message: "Play animation?",
//                    action: {
//                        self.BEO.playbackRecordingId = self.recordingId
//                        self.isShowing = false
//                        self.BEO.playAnimationRecording()
//                    },
//                    isEnabled: true
//                )
//            }
            
            CoreTextField("Name", text: $name)
            CoreTextField("Details", text: $details)
            
            HeaderText("Duration: \(duration.rounded()) seconds")
                .padding()
            
            // TODO: ADD TIMELINE OF ACTIONS
            Section(header: Text("Recorded Actions")) {
                RecordingActionsTimelineListView(recordingId: self.$recordingId)
                    .environmentObject(self.BEO)
            }.clearSectionBackground()
            
        }
        .padding()
        .navigationTitle("Recorded Animation")
        .onChange(of: self.recordingId, perform: { value in
            loadRecording()
        })
        .onAppear() {
            loadRecording()
        }
    }
    
    func loadRecording() {
        self.BEO.realmInstance.safeFindByField(Recording.self, value: self.recordingId) { obj in
            name = obj.name
            details = obj.details
            boardId = obj.boardId
            dateCreated = obj.dateCreated
            duration = obj.duration
        }
    }
}
