//
//  RecordingView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct RecordingListView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    
    var body: some View {
        NavigationStack {
            SearchableRecordingsListView(isShowing: self.$isShowing)
                .environmentObject(self.BEO)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
}


struct RecordingView: View {
    @State var recordingId: String
    @Binding var isShowing: Bool
    @EnvironmentObject var BEO: BoardEngineObject
    
    @State var name: String = ""
    @State var details: String = ""
    @State var boardId: String = ""
    @State var dateCreated: String = ""
    @State var duration: Double = 0.0

    var body: some View {
        Form {
            
            SolTextField("Name", text: $name)
            SolTextField("Details", text: $details)
            
            Text("Duration: \(duration, specifier: "%.2f") seconds")
                .font(.subheadline)
                .padding()
            
            DStack {
                SolConfirmButton(
                    title: "Save",
                    message: "Are you sure you want to save this Recording?",
                    action: {
                        self.BEO.realmInstance.safeFindByField(Recording.self, value: self.recordingId) { obj in
                            self.BEO.realmInstance.safeWrite { _ in
                                obj.name = name
                                obj.details = details
                                obj.dateCreated = dateCreated
                            }
                        }
                    }
                )
                
                SolConfirmButton(
                    title: "Delete",
                    message: "Are you sure you want to delete this Recording?",
                    action: {
                        self.BEO.realmInstance.safeFindByField(Recording.self, value: self.recordingId) { obj in
                            self.BEO.realmInstance.safeWrite { r in
                                r.delete(obj)
                                self.isShowing = false
                            }
                        }
                    }
                )
                
                SolConfirmButton(
                    title: "Load and Play",
                    message: "Play animation?",
                    action: {
                        self.BEO.playbackRecordingId = self.recordingId
                        self.isShowing = false
                        self.BEO.runAnimation()
                    }
                )
            }
            
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
