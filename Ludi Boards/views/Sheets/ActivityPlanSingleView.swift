//
//  ActivityPlanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Combine
import CoreEngine

// ActivityPlan View
struct ActivityPlanSingleView: View {

    @State var activityId: String
    @EnvironmentObject var BEO: BoardEngineObject
    @StateObject var APO: ActivityPlanObject = ActivityPlanObject()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var isLoading: Bool = false
    @State var realmInstance = realm()
    @State var confirmationPopupIsShowing = false
    @State private var refreshView = false
    @State private var showLoading = false
    @State private var showCompletion = false
    @State private var isCurrentPlan = false
    @State private var colorOpacity = 1.0
    @State var showShareSheet = false
    @State var cancellables = Set<AnyCancellable>()
    @State var isExpandedMore: Bool = true
    @State var isExpandedBoard: Bool = false
    
    @State var isEditMode: Bool = false
    
    func resetView() {
        refreshView = true
        refreshView = false
    }
    
    var body: some View {
        
        Form {
            
            DStack {
                SOLCON(
                    icon: SolIcon.save,
                    onTap: {
                        self.APO.saveToRealm()
                    }
                )
                
                SOLCON(
                    icon: SolIcon.load,
                    onTap: {
                        CodiChannel.SESSION_ON_ID_CHANGE.send(value: self.APO.id)
                        self.isCurrentPlan = true
                    }
                ).isEnabled(isEnabled: !self.isCurrentPlan)
                
                SOLCON(
                    icon: SolIcon.delete,
                    onTap: {
                        startLoadingProcess()
                        
                    }
                ).isEnabled(isEnabled: self.APO.sessionId != "SOL-LIVE-DEMO" && self.APO.sessionId != "SOL" && self.APO.id != "new")
                
                Spacer()
                Text(isEditMode ? "Done" : "Edit")
                    .foregroundColor(.blue)
                    .onTapAnimation {
                        isEditMode.toggle()
                    }
            }
            
            Section(header: Text(self.APO.title)) {
                CoreInputText(label: "Title", text: self.$APO.title, isEdit: $isEditMode)
                CoreInputText(label: "Sub-Title", text: self.$APO.subTitle, isEdit: $isEditMode)
            }
            DisclosureGroup("More Attributes and Settings", isExpanded: $isExpandedMore) {
                
                PickerTimeDuration(selection: self.$APO.duration, isEdit: $isEditMode)
                
                AdaptiveStack {
                    PickerAgeLevel(selection: self.$APO.ageLevel, isEdit: $isEditMode)
                    PickerNumberOfPlayers(selection: self.$APO.numOfPlayers, isEdit: $isEditMode)
                }
                
                AdaptiveStack {
                    PickerGroupCount(selection: self.$APO.numOfGroups, isEdit: $isEditMode)
                    PickerNumPerGroup(selection: self.$APO.numPerGroup, isEdit: $isEditMode)
                }

                AdaptiveStack {
                    InputTextMultiLine("Description", text: self.$APO.objectiveDetails, color: .black, isEdit: $isEditMode)
                        .frame(minHeight: 125)
                    InputTextMultiLine("Objective", text: self.$APO.activityDetails, color: .black, isEdit: $isEditMode)
                        .frame(minHeight: 125)
                }
                .padding(.bottom)
                .frame(minHeight: 150)
                
            }.clearSectionBackground()
            DisclosureGroup("Board Settings", isExpanded: $isExpandedBoard) {
                AlignLeft {
                    BodyText("Field Type: \(self.APO.backgroundView)")
                        .padding()
                }
                BarListPicker(initialSelected: self.isCurrentPlan ? self.BEO.boardBgName : self.APO.backgroundView, viewBuilder: self.BEO.boards.getAllMinis()) { v in
                    self.APO.backgroundView = v
                    if self.isCurrentPlan {
                        self.BEO.setBoardBgView(boardName: v)
                    }
                }
                .padding()
                .border(Color.secondaryBackground, width: 1.0)
                .cornerRadius(8)
                .shadow(color: .gray, radius: 10, x: 0, y: 0)
                .padding()
                
                DStack {
                    VStack {
                        AlignLeft {
                            BodyText("Background Color: \(self.APO.backgroundAlpha)", color: getFontColor(colorScheme))
                                .padding()
                        }
                        ColorListPicker() { color in
                            // Mirror into the plan so the pick persists on save.
                            if let c = color.toRGBA() {
                                self.APO.backgroundRed = c.red
                                self.APO.backgroundGreen = c.green
                                self.APO.backgroundBlue = c.blue
                                self.APO.backgroundAlpha = c.alpha
                            }
                            if self.isCurrentPlan {
                                self.BEO.setColor(colorIn: color)
                            }

                        }
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Background Color Transparency: \(self.APO.backgroundAlpha)", color: getFontColor(colorScheme))
                                .padding()
                        }
                        Slider(
                            value: self.$APO.backgroundAlpha,
                            in: 0.0...1.0,
                            step: 0.1,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        // The slider binds APO.backgroundAlpha —
                                        // push that value, not a stale local.
                                        self.BEO.boardBgAlpha = self.APO.backgroundAlpha
                                        self.BEO.boardBgColor = self.BEO.getColor()
                                    }

                                }
                            }
                        )
                        .padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                }
                
                DStack {
                    VStack {
//                        AlignLeft {
//                            SubHeaderText("Line Color: \(lineColor.uiColor.accessibilityName)", color: getFontColor(colorScheme))
//                                .padding()
//                        }
                        ColorListPicker() { color in
                            // Mirror into the plan so the pick persists on save.
                            if let c = color.toRGBA() {
                                self.APO.backgroundLineRed = c.red
                                self.APO.backgroundLineGreen = c.green
                                self.APO.backgroundLineBlue = c.blue
                                self.APO.backgroundLineAlpha = c.alpha
                            }
                            if self.isCurrentPlan {
                                self.BEO.setFieldLineColor(colorIn: color)
                            }

                        }
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                    VStack {
                        AlignLeft {
                            SubHeaderText("Rotate Field: \(Int(self.APO.backgroundRotation))", color: getFontColor(colorScheme))
                                .padding()
                        }
                        Slider(
                            value: self.$APO.backgroundRotation,
                            in: 0...360,
                            step: 45,
                            onEditingChanged: { editing in
                                if !editing {
                                    if self.isCurrentPlan {
                                        self.BEO.boardFeildRotation = self.APO.backgroundRotation
                                    }
                                    
                                }
                            }
                        ).padding()
                    }
                    .border(Color.secondaryBackground, width: 1.0)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
                    .padding()
                    
                }
                
                DStack {
                    
//                    VStack {
//                        AlignLeft {
//                            SubHeaderText("Line Width: \(Int(self.APO.lineStroke))", color: getFontColor(colorScheme))
//                                .padding()
//                        }
//                        Slider(
//                            value: self.APO.$lineStroke,
//                            in: 1.0...50.0,
//                            step: 1,
//                            onEditingChanged: { editing in
//                                if !editing {
//                                    if self.isCurrentPlan {
//                                        self.BEO.boardFeildLineStroke = self.APO.lineStroke
//                                    }
//                                }
//                            }
//                        ).padding()
//                    }
//                    .border(Color.secondaryBackground, width: 1.0)
//                    .cornerRadius(8)
//                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
//                    .padding()
                    
                    
//                    VStack {
//                        AlignLeft {
//                            SubHeaderText("Line Transparency: \(self.APO.lineOpacity)", color: getFontColor(colorScheme))
//                                .padding()
//                        }
//                        Slider(
//                            value: self.APO.$lineOpacity,
//                            in: 0.0...1.0,
//                            step: 0.1,
//                            onEditingChanged: { editing in
//                                if !editing {
//                                    if self.isCurrentPlan {
//                                        self.BEO.boardFieldLineAlpha = self.APO.lineOpacity
//                                        self.BEO.boardFieldLineColor = self.BEO.getFieldLineColor()
//                                    }
//                                }
//                            }
//                        ).padding()
//                    }
//                    .border(Color.secondaryBackground, width: 1.0)
//                    .cornerRadius(8)
//                    .shadow(color: .gray, radius: 10, x: 0, y: 0)
//                    .padding()
                       
                }
                
            }.clearSectionBackground()
                    

        }
        .background(getBackgroundColor(colorScheme))
        .onAppear() {
            if self.activityId == "new" {
                self.isEditMode = true
            }
            self.APO.loadActivityPlan(byId: self.activityId)
        }
    }
    
 

    func startLoadingProcess() {
        isLoading = true
        // Simulate a network request or some processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCompletion = false
            }
        }
    }
    
}

