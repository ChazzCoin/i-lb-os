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

extension View {
    func deviceFullSize() -> some View {
        self.modifier(DeviceFullSize())
    }
}


struct BinauralSoundView: View {
    // Optional explicit room (else uses AppStorage)
    @EnvironmentObject public var USER: UserToolsObservable
    private let explicitRoomId: String?
    @AppStorage("currentRoomId") private var storedRoomId: String = ""

    @StateObject private var participantsVM = ParticipantsController()
    @StateObject private var vm: BinauralSoundViewModel
    @Environment(\.colorScheme) private var colorScheme

    // Precise control state (top-level)
    @State private var beatLinkOn: Bool = true
    @State private var beatDelta: Double = 0
    @State private var snapL: Bool = false
    @State private var snapR: Bool = false
    @State private var aRef: Double = 440.0

    init(roomId: String? = nil) {
        self.explicitRoomId = roomId
        _vm = StateObject(wrappedValue: BinauralSoundViewModel())
    }

    // Computeds
//    private var allParticipantsReady: Bool {
//        !vm.participants.isEmpty && vm.participants.values.allSatisfy { $0 }
//    }
//    private var canPlay: Bool { vm.isReady && allParticipantsReady }
//    private var selfJoined: Bool { vm.participants.keys.contains(vm.currentUserId) }
//    private var selfReady: Bool { vm.participants[vm.currentUserId] == true }

    var body: some View {
        let roomId = explicitRoomId ?? storedRoomId

        ScrollView {
            VStack(spacing: 24) {

                // Header + Group
                VStack(spacing: 8) {
                    Text("Binaural Meditation")
                        .font(.largeTitle.bold())
                        .foregroundColor(.accentColor)
                        .padding(.top)
                        .shadow(radius: 2)

                    groupParticipationCard
                }
                .padding(.horizontal)

                // Room + Preset controls
                presetCard(roomId: roomId)
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
                            Image(systemName:"arrow.down.circle.dotted").font(.system(size: 40))
                            Text("Load It In").font(.title2.bold())
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
            let roomId = self.USER.currentRoomId ?? "default-room"
            let sessionId = vm.currentPresetId ?? "default-session"
            participantsVM.start(roomId: roomId, sessionId: sessionId)
        }
        .onDisappear {
            participantsVM.stop()
        }
        .onChange(of: storedRoomId) { newId in
            guard explicitRoomId == nil else { return }
            vm.roomId = newId
        }
    }
    private var selfJoined: Bool {
        participantsVM.participants[participantsVM.currentUserId] != nil
    }
    private var selfReady: Bool {
        participantsVM.participants[participantsVM.currentUserId]?.isReady == true
    }
    private var allParticipantsReady: Bool {
        participantsVM.allReady
    }

    // MARK: - Subviews

    private var groupParticipationCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Group Participation").font(.headline)
                Spacer()
                // Live status pill from your audio VM
                Text(vm.isPlaying ? "Live: Playing" : "Standby")
                    .font(.caption2)
                    .padding(.vertical, 4).padding(.horizontal, 8)
                    .background(vm.isPlaying ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(vm.isPlaying ? .green : .secondary)
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Button {
                    // Join this session’s participants list
                    participantsVM.join(
                        userName: generateRandomName(), // or your own name source
                        widgetType: .binaural,
                        widgetId: vm.currentPresetId ?? "binaural-default"
                    )
                } label: {
                    Label(selfJoined ? "Joined" : "Join Group", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .disabled(selfJoined)

                if selfReady {
                    Button {
                        participantsVM.setReady(false)
                    } label: {
                        Label("I'm Not Ready", systemImage: "xmark.seal")
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        participantsVM.setReady(true)
                    } label: {
                        Label("I'm Ready", systemImage: "checkmark.seal")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!selfJoined)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: allParticipantsReady ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(allParticipantsReady ? .green : .gray)
                    Text("\(participantsVM.ready)/\(participantsVM.total) ready")
                        .font(.caption).monospacedDigit().foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                if participantsVM.participants.isEmpty {
                    Text("No participants yet.")
                        .font(.subheadline).foregroundStyle(.secondary)
                } else {
                    ForEach(
                        participantsVM.participants.values.sorted(by: { $0.userName < $1.userName }),
                        id: \.userId
                    ) { p in
                        HStack {
                            Image(systemName: p.isReady ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(p.isReady ? .green : .gray)
                            Text(p.userId == participantsVM.currentUserId ? "You" : (p.userName.isEmpty ? "User \(p.userId.prefix(6))" : p.userName))
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .shadow(radius: 2)
    }


    private func presetCard(roomId: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label("Room", systemImage: "rectangle.3.group.bubble.left")
                Spacer()
                Text(roomId.isEmpty ? "—" : roomId)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Preset Name", systemImage: "tag")
                Spacer()
                TextField("Untitled Preset", text: $vm.presetName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 280)
                    .disabled(!vm.isReady)
            }

            HStack(spacing: 12) {
                Button("Save / Update (Room)") { vm.saveOrUpdateForRoom(name: vm.presetName) }
                    .buttonStyle(.borderedProminent)
                    .disabled(!vm.isReady)

                Button("Load Latest") { vm.refreshData() }
                    .buttonStyle(.bordered)

                Button(role: .destructive) { vm.deleteCurrentForRoom() } label: { Text("Delete") }
                    .buttonStyle(.bordered)
                    .disabled(vm.currentPresetId == nil)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .shadow(radius: 2)
    }

    private var controlsCard: some View {
        VStack(spacing: 16) {
            // Hemi readout
            HStack {
                Label("Hemi-Sync", systemImage: "waveform.circle")
                Spacer()
                Text("\(Int(vm.hemiFreq)) Hz").monospacedDigit().foregroundStyle(.secondary)
            }

            // Left
            PrecisionControl(
                label: "Left Freq",
                icon: "waveform.path.ecg",
                value: Binding(
                    get: { vm.freqLeft },
                    set: { newVal in
                        let v = Double(Int(max(newVal, 1)))
                        if beatLinkOn { beatDelta = max(0, vm.freqRight - v) }
                        vm.freqLeft = v
                    }
                ),
                range: 1...1000,
                coarseStep: 1,
                fineStep: 1,
                decimals: 2,
                unit: "Hz",
                disabled: !vm.isReady
            )

            // Right + Beat Link
            VStack(spacing: 8) {
                PrecisionControl(
                    label: "Right Freq",
                    icon: "waveform.path.ecg",
                    value: Binding(
                        get: { vm.freqRight },
                        set: { newVal in
                            let v = Double(Int(max(newVal, 1)))
                            if beatLinkOn { beatDelta = max(0, v - vm.freqLeft) }
                            vm.freqRight = v
                        }
                    ),
                    range: 1...1000,
                    coarseStep: 1,
                    fineStep: 1,
                    decimals: 2,
                    unit: "Hz",
                    disabled: !vm.isReady
                )
//
//                HStack(spacing: 12) {
//                    Toggle(isOn: $beatLinkOn) {
//                        Label("Link Δ (beat)", systemImage: "link")
//                    }
//                    .toggleStyle(.switch)
//                    .disabled(!vm.isReady)
//
//                    PrecisionControl(
//                        label: "Δ",
//                        icon: "waveform.badge.plus",
//                        value: Binding(
//                            get: { beatDelta },
//                            set: { newDelta in
//                                beatDelta = max(0, newDelta)
//                                if beatLinkOn { vm.freqRight = vm.freqLeft + beatDelta }
//                            }
//                        ),
//                        range: 0...1000,
//                        coarseStep: 1,
//                        fineStep: 1,
//                        decimals: 2,
//                        unit: "Hz",
//                        disabled: !vm.isReady
//                    )
//
//                    Spacer()
//
//                    VStack(alignment: .trailing, spacing: 2) {
//                        Text("Beat: \(abs(vm.freqRight - vm.freqLeft), specifier: "%.0f") Hz")
//                            .font(.caption).monospacedDigit().foregroundStyle(.secondary)
//                        Text("Binaural: \(vm.freqLeft < vm.freqRight ? "R>L" : (vm.freqLeft > vm.freqRight ? "L>R" : "—"))")
//                            .font(.caption2).foregroundStyle(.secondary)
//                    }
//                }
//                .onChange(of: vm.freqLeft) { _ in if beatLinkOn { vm.freqRight = vm.freqLeft + beatDelta } }
//                .onChange(of: vm.freqRight) { _ in beatDelta = max(0, abs(vm.freqRight - vm.freqLeft)) }
            }

            // Note snapping (optional manual apply)
//            NoteSnapper(freq: $vm.freqLeft,  snapEnabled: $snapL, aRef: $aRef, disabled: !vm.isReady)
//            NoteSnapper(freq: $vm.freqRight, snapEnabled: $snapR, aRef: $aRef, disabled: !vm.isReady)

            // Duration
            DurationField(seconds: $vm.duration, disabled: !vm.isReady)

            // Sample Rate
//            HStack {
//                Label("Sample Rate", systemImage: "waveform")
//                Spacer()
//                Picker("", selection: $vm.sampleRate) {
//                    Text("43,200").tag(43200.0)
//                    Text("44,000").tag(44000.0)
//                }
//                .pickerStyle(.segmented)
//                .frame(maxWidth: 280)
//                .disabled(!vm.isReady)
//            }

            // Fade
//            PrecisionControl(
//                label: "Fade Time",
//                icon: "arrow.right.to.line",
//                value: $vm.fadeTime,
//                range: 0.05...60,
//                coarseStep: 0.5,
//                fineStep: 0.05,
//                decimals: 2,
//                unit: "s",
//                disabled: !vm.isReady
//            )
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
