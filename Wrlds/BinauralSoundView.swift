//
//  Untitled.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/8/25.
//

import SwiftUI
import RealmSwift
import CoreEngine
import Foundation

struct DeviceFullWidth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.main.bounds.width)
    }
}

extension View {
    func deviceFullWidth() -> some View {
        self.modifier(DeviceFullWidth())
    }
}
struct DeviceFullHeight: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: UIScreen.main.bounds.height)
    }
}

extension View {
    func deviceFullHeight() -> some View {
        self.modifier(DeviceFullHeight())
    }
}
struct DeviceFullSize: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
    }
}

public func roundTo(_ value: Double, places: Int) -> Double {
    var d = String(format: "%.\(places)f", value)
    return Double(d) ?? 0.0
}
extension View {
    func deviceFullSize() -> some View {
        self.modifier(DeviceFullSize())
    }
}


struct BinauralSoundView: View {
    // Optional explicit room (else uses AppStorage)
    @EnvironmentObject public var USER: UserToolsObservable
    private let explicitRoomId: String?
//    @AppStorage("currentRoomId") private var currentRoomId: String = ""
//    @AppStorage("currentWidgetId") private var currentWidgetId: String = ""
//    @AppStorage("currentSessionId") private var currentSessionId: String = ""

    @StateObject private var participantsVM = ParticipantsController()
    @StateObject private var vm: BinauralSoundViewModel
    @Environment(\.colorScheme) private var colorScheme

    // Precise control state (top-level)
    @State private var fineTunedControl: Bool = false
    @State private var saveControls: Bool = false
    @State private var beatLinkOn: Bool = true
    @State private var beatDelta: Double = 0
    @State private var snapL: Bool = false
    @State private var snapR: Bool = false
    @State private var aRef: Double = 440.0

    init(roomId: String? = nil) {
        self.explicitRoomId = roomId
        _vm = StateObject(wrappedValue: BinauralSoundViewModel())
    }

    var body: some View {

        ScrollView {
            VStack(spacing: 24) {

                // Header + Group
                VStack(spacing: 8) {
                    Text("Binaural Meditation")
                        .font(.largeTitle.bold())
                        .foregroundColor(.accentColor)
                        .padding(.top)
                        .shadow(radius: 2)
                    
                    self.participantsVM.Display()
                    
                }
                .padding(.horizontal)

                // Controls Card
                controlsCard
                    .padding(.horizontal)

                // Rebuild buffer CTA
                if vm.hasChanged {
                    Button {
                        vm.prepareAudioBuffer()
                    } label: {
                        HStack {
                            Image(systemName:"arrow.down.circle.dotted")
                                .font(.system(size: 40))
                            Text("Load It In")
                                .font(.title2.bold())
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(18)
                        .shadow(radius: 6)
                    }
                    .padding(.horizontal)
                    .animation(.spring(), value: vm.hasChanged)
                }

                // Play/Pause — realtime synced by ViewModel
                if vm.isReady {
                    HStack {
                        Image(systemName: vm.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40))
                        Text(vm.isPlaying ? "Stop" : "Play")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(radius: 6)
                    .onTapAnimation {
                        vm.isPlaying ? vm.stop() : vm.play()
                    }
                } else {
                    HStack {
                        Image(systemName: vm.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40))
                        Text("PLEASE WAIT: LOADING!")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(radius: 6)
                }
                


                // Progress + Visualizer
                if vm.isPlaying {
                    VStack(spacing: 8) {
                        ProgressView(value: vm.playbackTime, total: vm.duration)
                            .progressViewStyle(LinearProgressViewStyle())
                            .animation(.linear, value: vm.playbackTime)
                        Text("Time: \(Int(vm.playbackTime)) / \(Int(vm.duration)) sec")
                            .font(.caption).foregroundColor(.secondary)

                        WaveformVisualizer(progress: max(0, min(1, vm.playbackTime / max(1, vm.duration))))
                            .frame(height: 64)
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                    }
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            vm.restartFirebaseObservers()
            beatDelta = abs(vm.freqRight - vm.freqLeft)
            self.vm.setUserId(user: USER.currentUserId)
            if self.USER.currentRoomId.isEmpty {
                self.USER.currentRoomId = "Demo"
            }
            if self.USER.currentWidgetId.isEmpty {
                self.USER.currentWidgetId = "hemi-sync"
            }
            if self.USER.currentSessionId.isEmpty {
                self.USER.currentSessionId = "default-session"
            }
            self.vm.currentPresetId = self.USER.currentSessionId
            self.participantsVM.start(roomId: self.USER.currentRoomId, sessionId: self.USER.currentSessionId)
        }
        .onDisappear {
            participantsVM.stop()
        }
    }

    private func presetCard(roomId: String) -> some View {
        VStack(spacing: 12) {
            CoreButton(title: "Save / Update (Room)", action: {vm.saveOrUpdateForRoom(name: vm.presetName)}, isEnabled: true)
            HStack {
                CoreButton(title: "Load Latest", action: {vm.refreshData()}, isEnabled: true)
                CoreButton(title: "Delete", action: {vm.deleteCurrentForRoom()}, isEnabled: vm.currentPresetId.isEmpty)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .shadow(radius: 2)
        .padding()
    }

    private var controlsCard: some View {
        VStack(spacing: 16) {

            AlignmentHemiSyncPickerCompact(leftHz: $vm.freqLeft, rightHz: $vm.freqRight)
            
            DurationField(seconds: $vm.duration, disabled: !vm.isReady)
            DisclosureGroup(isExpanded: $fineTunedControl, content: {
                VStack {
                    // Left
                    PrecisionControl(
                        label: "Left Freq",
                        icon: "waveform.path.ecg",
                        value: Binding(
                            get: { vm.freqLeft },
                            set: { newVal in
                                let rounded = (newVal * 100).rounded() / 100
                                if beatLinkOn {
                                    beatDelta = max(0, vm.freqRight - rounded)
                                }
                                vm.freqLeft = rounded
                            }
                        ),
                        range: 1...1000,
                        coarseStep: 0.1,
                        fineStep: 0.01,
                        decimals: 2,
                        unit: "Hz",
                        disabled: !vm.isReady
                    )

                    PrecisionControl(
                        label: "Right Freq",
                        icon: "waveform.path.ecg",
                        value: Binding(
                            get: { vm.freqRight },
                            set: { newVal in
                                let rounded = (newVal * 100).rounded() / 100
                                if beatLinkOn {
                                    beatDelta = max(0, rounded - vm.freqLeft)
                                }
                                vm.freqRight = rounded
                            }
                        ),
                        range: 1...1000,
                        coarseStep: 0.1,
                        fineStep: 0.01,
                        decimals: 2,
                        unit: "Hz",
                        disabled: !vm.isReady
                    )

                }
            }, label: {
                Label("Fine-Tune Frequencies", systemImage: "waveform.circle")
            })
            
            DisclosureGroup(isExpanded: $saveControls, content: {
                VStack(spacing: 12) {
                    CoreButton(title: "Save / Update (Room)", action: {vm.saveOrUpdateForRoom(name: vm.presetName)}, isEnabled: true)
                    HStack {
                        CoreButton(title: "Load Latest", action: {vm.refreshData()}, isEnabled: true)
                        CoreButton(title: "Delete", action: {vm.deleteCurrentForRoom()}, isEnabled: !vm.currentPresetId.isEmpty)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                .shadow(radius: 2)
            }, label: {
                Label("Save/Load/Update", systemImage: "waveform.circle")
            })


        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                .shadow(radius: 8)
        )
    }
}


struct WaveformVisualizer: View {
    var progress: Double
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(0..<60) { i in
                    let amp = sin(Double(i) / 10.0 + progress * 6.28) * 0.8 + Double.random(in: -0.08...0.08)
                    Capsule()
                        .frame(width: 3, height: CGFloat(abs(amp)) * geo.size.height * 0.5)
                        .foregroundColor(Color.blue.opacity(0.7))
                        .animation(.easeInOut(duration: 0.15), value: progress)
                }
            }
        }
    }
}
