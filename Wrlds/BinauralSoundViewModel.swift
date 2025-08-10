import SwiftUI
import AVFoundation
import Foundation
import RealmSwift
import CoreEngine
import FirebaseDatabase

@inline(__always)
private func threadRealm() -> Realm {
    // If you have a custom config, use it here
    return try! Realm()
}


@MainActor
public final class BinauralSoundViewModel: ObservableObject {
    // MARK: - App/Room
    @ObservedObject public var fusedRealmFire: FusedRealmFire<BinauralSound> = FusedRealmFire<BinauralSound>()
    @AppStorage("currentUserId", store: UserDefaults(suiteName: "worlds")) public var currentUserId: String = ""
    @AppStorage("currentRoomId", store: UserDefaults(suiteName: "worlds")) public var roomId: String = "Alicia" {
        didSet { if oldValue != roomId { restartFirebaseObservers() } }
    }

    // MARK: - Types
    public enum PlaybackStatus: String { case idle, playing }

    // MARK: - Firebase
    private let reference: DatabaseReference = Database.database().reference()
    private var hAdded: DatabaseHandle?
    private var hChanged: DatabaseHandle?
    private var hRemoved: DatabaseHandle?

    // MARK: - Realm access
    /// Always create a fresh Realm on the calling thread (don’t cache/share).
    private func threadRealm() -> Realm { try! Realm() }

    // MARK: - Participants
    @Published public private(set) var participants: [String: Bool] = [:] // [userId: isReady]


    // MARK: - Current preset
    @Published public private(set) var currentPresetId: String?
    @Published public var presetName: String = "Untitled Preset"
    @Published public var isUpdating: Bool = false
    // MARK: - Synth Params
    @Published public var duration: Double = 600.0  { didSet { hasChanged = true } }
    @Published public var sampleRate: Double = 43200.0 { didSet { hasChanged = true } }
    @Published public var freqLeft: Double = 60.0   { didSet { hasChanged = true; hemiFreq = abs(freqLeft - freqRight) } }
    @Published public var freqRight: Double = 100.0 { didSet { hasChanged = true; hemiFreq = abs(freqLeft - freqRight) } }
    @Published public var fadeTime: Double = 0.0    { didSet { hasChanged = true } }
    @Published public var modFreq: Double = 0.1     { didSet { hasChanged = true } }
    @Published public var modDepth: Double = 0.3    { didSet { hasChanged = true } }
    @Published public var overtoneLevel: Double = 0.10 { didSet { hasChanged = true } }
    @Published public var overtoneMultiplier: Double = 2.0 { didSet { hasChanged = true } }

    // Derived
    @Published public private(set) var hemiFreq: Double = 40.0

    // MARK: - Group state
    @Published public private(set) var users: Int = 0
    @Published public private(set) var usersReady: Int = 0
    @Published public private(set) var status: PlaybackStatus = .idle

    // MARK: - UI/State
    @Published public private(set) var hasChanged: Bool = false
    @Published public private(set) var isReady: Bool = true
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var playbackTime: Double = 0.0

    // MARK: - Audio
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioBuffer: AVAudioPCMBuffer?
    private var timer: Timer?

    // MARK: - Init / Deinit
    public init() {
        
        print("Current User ID: \(self.currentUserId)")
        self.refreshData()
//        loadOrCreateForRoom(roomId)
        prepareAudioBuffer()
        if !roomId.isEmpty { startFirebaseObservers() }
    }
    
    public func refreshData() {
        let path = DatabasePaths.binauralSounds.rawValue
        
        self.fusedRealmFire.load(lifeId: self.roomId, path: path) { obj in
            self.applySnapshotOnMain(obj.toDictionary())
        }
    }
    public func setUserId(user: String) {
        self.currentUserId = user
    }
//    deinit { stop(); removeFirebaseObservers() }

    // MARK: - Firebase observers
    public func restartFirebaseObservers() {
        guard !roomId.isEmpty else { return }
        
        startFirebaseObservers()
    }

    private func startFirebaseObservers() {
        guard !roomId.isEmpty else { return }
        // Changed
        self.fusedRealmFire.observeFire(
            onAdded: { obj in
                print("On Added FusedRealmFired!!!!!")
            },
            onChange: { obj in
                print("On Change FusedRealmFired!!!!!")
                self.applySnapshotOnMain(obj.toDictionary())
                self.reactToRemoteStatus(obj.toDictionary())
                self.fusedRealmFire.resetHasChanged()
            },
            onDelete: { obj in
                print("On Deleted FusedRealmFired!!!!!")
//                self.deleteRealmBackground(id: removedId)
//                self.loadLatestForRoom()
            }
        )

    }


    // MARK: - Realm writes (background)
//    private func writeRealmBackground(_ dict: [String: Any]) {
//        DispatchQueue.global(qos: .utility).async {
//            autoreleasepool {
//                let realm = self.threadRealm()
//                let obj = self.unmanagedFrom(dict)
//                try? realm.write { realm.add(obj, update: .modified) }
//            }
//        }
//    }
//
//    private func deleteRealmBackground(id: String) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            autoreleasepool {
//                let realm = self.threadRealm()
//                if let obj = realm.object(ofType: BinauralSound.self, forPrimaryKey: id) {
//                    try? realm.write { realm.delete(obj) }
//                }
//            }
//        }
//    }

    // MARK: - Apply snapshot (main)
    private func applySnapshotOnMain(_ dict: [String: Any]) {
        // Build a fresh unmanaged snapshot on MAIN, copy scalars to @Published.
        DispatchQueue.main.async {
            let s = self.unmanagedFrom(dict)
            guard s.roomId == self.roomId || self.roomId.isEmpty else { return }

            self.presetName          = s.name
            self.duration            = s.duration
            self.sampleRate          = s.sampleRate
            self.freqLeft            = s.freqLeft
            self.freqRight           = s.freqRight
            self.fadeTime            = s.fadeTime
            self.modFreq             = s.modFreq
            self.modDepth            = s.modDepth
            self.overtoneLevel       = s.overtoneLevel
            self.overtoneMultiplier  = s.overtoneMultiplier
            self.currentPresetId     = s.id

            self.users               = s.users
            self.usersReady          = s.usersReady
            self.status              = PlaybackStatus(rawValue: s.status) ?? .idle

            if let parts = dict["participants"] as? [String: Bool] {
                self.participants = parts
            } else {
                self.participants = self.participants // no-op
            }

            self.hasChanged = false
            self.prepareAudioBuffer()
        }

    }

    private func reactToRemoteStatus(_ dict: [String: Any]) {
        let stat  = (dict["status"] as? String) ?? "idle"
        let by    =  dict["lastUpdatedBy"] as? String
        let start =  dict["playStartAt"] as? TimeInterval // ms

        guard by != currentUserId else { return }

        if stat == PlaybackStatus.playing.rawValue {
            ensureAudioReadyThen { if !self.isPlaying { self.startLocalPlayback(alignedTo: start) } }
        } else {
            if isPlaying { stopLocalPlaybackWithoutPushing() }
        }
    }

    // MARK: - Room-scoped loading (main)
//    public func loadLatestForRoom() {
//        guard !roomId.isEmpty else { return }
//        let realm = threadRealm()
//        if let latest = realm.objects(BinauralSound.self)
//            .filter("roomId == %@", roomId)
//            .sorted(byKeyPath: "dateUpdated", ascending: false)
//            .first
//        {
//            applySnapshotOnMain(latest.toFirebaseDict())
//        } else {
//            self.createNewSound(roomId: roomId, name: "Room \(roomId)")
//            if let created = realm.objects(BinauralSound.self)
//                .filter("roomId == %@", roomId)
//                .sorted(byKeyPath: "dateCreated", ascending: false)
//                .first
//            {
//                applySnapshotOnMain(created.toFirebaseDict())
//            }
//        }
//    }

//    private func loadOrCreateForRoom(_ roomId: String) {
//        guard !roomId.isEmpty else { return }
//        loadLatestForRoom()
//    }

    // MARK: - Model snapshot helpers
    private func unmanagedFrom(_ dict: [String: Any]) -> BinauralSound {
        let s = BinauralSound()
        s.id = dict["id"] as? String ?? dict["roomId"] as? String ?? "Alicia"
        s.roomId = dict["roomId"] as? String ?? ""
        s.name = dict["name"] as? String ?? "Untitled Preset"

        func dbl(_ key: String, _ def: Double) -> Double {
            if let v = dict[key] as? Double { return v }
            if let v = dict[key] as? Int { return Double(v) }
            if let v = dict[key] as? NSNumber { return v.doubleValue }
            return def
        }
        s.duration           = dbl("duration", 600)
        s.sampleRate         = dbl("sampleRate", 43200)
        s.freqLeft           = dbl("freqLeft", 60)
        s.freqRight          = dbl("freqRight", 100)
        s.fadeTime           = dbl("fadeTime", 3)
        s.modFreq            = dbl("modFreq", 0.1)
        s.modDepth           = dbl("modDepth", 0.3)
        s.overtoneLevel      = dbl("overtoneLevel", 0.1)
        s.overtoneMultiplier = dbl("overtoneMultiplier", 2)
        s.users              = Int(dbl("users", 0))
        s.usersReady         = Int(dbl("usersReady", 0))
        s.status             = (dict["status"] as? String) ?? PlaybackStatus.idle.rawValue
        s.lastUpdatedBy = (dict["lastUpdatedBy"] as? String) ?? "unknown"
        if let createdTS = dict["dateCreated"] as? String {
            s.dateCreated = createdTS
        }
        if let updatedTS = dict["dateUpdated"] as? String {
            s.dateUpdated = updatedTS
        }
        return s
    }

    private func toModel(existing: BinauralSound? = nil) -> BinauralSound {
        let m = existing ?? BinauralSound()
        m.roomId             = roomId
        m.name               = presetName.isEmpty ? "Room \(roomId)" : presetName
        m.duration           = duration
        m.sampleRate         = sampleRate
        m.freqLeft           = freqLeft
        m.freqRight          = freqRight
        m.fadeTime           = fadeTime
        m.modFreq            = modFreq
        m.modDepth           = modDepth
        m.overtoneLevel      = overtoneLevel
        m.overtoneMultiplier = overtoneMultiplier
        m.users              = users
        m.usersReady         = usersReady
        m.status             = status.rawValue
        m.dateUpdated        = getTimeStamp()
        m.lastUpdatedBy     = currentUserId
        if existing == nil { m.dateCreated = getTimeStamp() }
        return m
    }

    // MARK: - CRUD (main thread)
    public func saveOrUpdateForRoom(name: String? = nil) {
        if let n = name { presetName = n }
        let realm = threadRealm()
        var target: BinauralSound?

        try? realm.write {
            if let existing = realm.objects(BinauralSound.self)
                .filter("roomId == %@", roomId)
                .sorted(byKeyPath: "dateUpdated", ascending: false)
                .first
            {
                target = toModel(existing: existing)
            } else {
                let created = toModel(existing: nil)
                realm.add(created, update: .modified)
                target = created
            }
        }

        if let t = target {
            currentPresetId = t.id
            hasChanged = false
            pushPresetToFirebase(t)
        }
    }

    public func deleteCurrentForRoom() {
        guard let id = currentPresetId else { return }
        let realm = threadRealm()
        try? realm.write {
            if let obj = realm.object(ofType: BinauralSound.self, forPrimaryKey: id),
               obj.roomId == roomId {
                realm.delete(obj)
            }
        }
        // remove from Firebase
        let path = DatabasePaths.binauralSounds.rawValue
        reference.child(path).child(roomId).removeValue()
//        loadLatestForRoom()
    }

    private func pushPresetToFirebase(_ sound: BinauralSound) {
        let path = DatabasePaths.binauralSounds.rawValue
        var payload = sound.toFirebaseDict()
        payload["dateUpdated"] = getTimeStamp()
        payload["dateCreated"] = getTimeStamp()
        payload["status"] = self.status.rawValue
        payload["lastUpdatedBy"] = self.currentUserId
        reference.child(path).child(sound.roomId).setValue(payload)
    }

    // MARK: - Participants
    public func joinGroup() {
        participants[currentUserId] = false
        users = participants.count
        usersReady = participants.values.filter { $0 }.count
        pushParticipantsPatch()
    }

    public func markReady(_ ready: Bool) {
        participants[currentUserId] = ready
        users = participants.count
        usersReady = participants.values.filter { $0 }.count
        pushParticipantsPatch()
    }

    private func pushParticipantsPatch() {
//        guard let id = currentPresetId else { return }
        let path = DatabasePaths.binauralSounds.rawValue
        reference.child(path).child(roomId).updateChildValues([
            "participants": participants,
            "lastUpdatedBy": self.currentUserId,
            "users": participants.count,
            "usersReady": participants.values.filter { $0 }.count,
            "dateUpdated": getTimeStamp()
        ])
    }

    // MARK: - Remote status patch
    private func updateRemoteStatus(_ newStatus: PlaybackStatus, startedAt: Any? = nil) {
        DispatchQueue.main.async {
            let path = DatabasePaths.binauralSounds.rawValue
            var patch: [String: Any] = [
                "status": newStatus.rawValue,
                "lastUpdatedBy": self.currentUserId,
                "dateUpdated": getTimeStamp()
            ]
            patch["playStartAt"] = (newStatus == .playing) ? (startedAt ?? getTimeStamp()) : NSNull()
            patch["lastUpdatedBy"] = self.currentUserId
            self.reference.child(path).child(self.roomId).updateChildValues(patch)
        }
        
    }

    // MARK: - Audio buffer (background)
    public func prepareAudioBuffer() {
        guard isReady else { return }
        isReady = false

        let duration   = max(0.1, self.duration)
        let sampleRate = self.sampleRate
        let freqLeft   = Double(self.freqLeft)
        let freqRight  = Double(self.freqRight)
        let fadeTime   = max(0.0, self.fadeTime)
        let modFreq    = max(0.0, self.modFreq)
        let modDepth   = max(0.0, min(1.0, self.modDepth))
        let overtoneLevel = max(0.0, self.overtoneLevel)
        let overtoneMultiplier = max(1.0, self.overtoneMultiplier)

        DispatchQueue.global(qos: .userInitiated).async {
            let nSamples = Int(sampleRate * duration)
            guard nSamples > 0,
                  let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(nSamples)) else {
                DispatchQueue.main.async { self.isReady = true }
                return
            }

            buffer.frameLength = AVAudioFrameCount(nSamples)
            let left  = buffer.floatChannelData![0]
            let right = buffer.floatChannelData![1]

            for i in 0..<nSamples {
                let t = Double(i) / sampleRate
                var env: Double = 1.0
                if t < fadeTime { env = t / max(0.001, fadeTime) }
                else if t > duration - fadeTime { env = max(0, (duration - t) / max(0.001, fadeTime)) }
                let mod = 1 - (modDepth * sin(2 * .pi * modFreq * t))
                let baseL = sin(2 * .pi * freqLeft * t)
                let overtoneL = overtoneLevel * sin(2 * .pi * freqLeft * overtoneMultiplier * t)
                let baseR = sin(2 * .pi * freqRight * t)
                let overtoneR = overtoneLevel * sin(2 * .pi * freqRight * overtoneMultiplier * t)
                left[i]  = Float((baseL + overtoneL) * env * mod)
                right[i] = Float((baseR + overtoneR) * env * mod)
            }

            // Simple normalization
            let lbuf  = UnsafeBufferPointer(start: left,  count: nSamples)
            let rbuf  = UnsafeBufferPointer(start: right, count: nSamples)
            let maxSample = max(lbuf.max() ?? 0, abs(lbuf.min() ?? 0), rbuf.max() ?? 0, abs(rbuf.min() ?? 0))
            if maxSample > 1 {
                let k = Float(1.0 / maxSample)
                for i in 0..<nSamples { left[i] *= k; right[i] *= k }
            }

            DispatchQueue.main.async {
                self.audioBuffer = buffer
                self.isReady = true
                self.hasChanged = false
                self.isUpdating = false
            }
        }
    }

    // MARK: - Playback (realtime synced)
    public func play() {
        ensureAudioReadyThen {
            guard !self.isPlaying else { return }
            self.startLocalPlayback(alignedTo: nil)
            self.updateRemoteStatus(.playing, startedAt: getTimeStamp())
        }
    }

    public func stop() {
        stopLocalPlaybackWithoutPushing()
        updateRemoteStatus(.idle)
    }

    private func startLocalPlayback(alignedTo playStartAtMs: TimeInterval?) {
        guard let baseBuffer = audioBuffer, !isPlaying else { return }

        let engine = AVAudioEngine()
        let node   = AVAudioPlayerNode()
        audioEngine = engine
        playerNode  = node

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: baseBuffer.format)

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()

        func scheduleAndStart(_ buffer: AVAudioPCMBuffer) {
            self.updateRemoteStatus(.playing)
            DispatchQueue.main.async {
                node.play()
            }
            node.scheduleBuffer(buffer, at: nil, options: .interrupts) { [weak self] in
                self?.stopLocalPlaybackWithoutPushing()
            }
        }

        guard let ms = playStartAtMs else {
            scheduleAndStart(baseBuffer); finalizeStart(); return
        }

        let nowMs = Date().timeIntervalSince1970 * 1000
        let elapsed = max(0, (nowMs - ms) / 1000.0)

        if elapsed <= 0 || elapsed >= duration {
            scheduleAndStart(baseBuffer); finalizeStart(); return
        }

        let sr = baseBuffer.format.sampleRate
        let startFrame = AVAudioFramePosition(min(elapsed * sr, Double(baseBuffer.frameLength - 1)))
        let framesLeft = AVAudioFrameCount(max(0, Int(baseBuffer.frameLength) - Int(startFrame)))

        DispatchQueue.global(qos: .userInitiated).async {
            guard
                let format  = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2),
                let trimmed = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: framesLeft),
                let srcL    = baseBuffer.floatChannelData?[0],
                let srcR    = baseBuffer.floatChannelData?[1]
            else {
                DispatchQueue.main.async { scheduleAndStart(baseBuffer); self.finalizeStart() }
                return
            }

            trimmed.frameLength = framesLeft
            if let dstL = trimmed.floatChannelData?[0], let dstR = trimmed.floatChannelData?[1] {
                let sf = Int(startFrame)
                memcpy(dstL, srcL.advanced(by: sf), Int(framesLeft) * MemoryLayout<Float>.size)
                memcpy(dstR, srcR.advanced(by: sf), Int(framesLeft) * MemoryLayout<Float>.size)
            }

            DispatchQueue.main.async { scheduleAndStart(trimmed); self.finalizeStart() }
        }
    }

    private func finalizeStart() {
        isPlaying = true
        playbackTime = 0.0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.playbackTime += 1.0
            if self.playbackTime >= self.duration { self.stopLocalPlaybackWithoutPushing() }
        }
        DispatchQueue.main.async {
            self.status = .playing
            
        }
        
    }

    private func stopLocalPlaybackWithoutPushing() {
        DispatchQueue.main.async {
            self.timer?.invalidate(); self.timer = nil
            self.playerNode?.stop()
            self.audioEngine?.stop()
            self.isPlaying = false
            self.playbackTime = 0.0
            self.status = .idle
        }
        
    }

    private func ensureAudioReadyThen(_ work: @escaping () -> Void) {
        if audioBuffer != nil && isReady { work(); return }
        prepareAudioBuffer()
        var tries = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            tries += 1
            if self.audioBuffer != nil && self.isReady { t.invalidate(); work() }
            else if tries > 60 { t.invalidate() }
        }
    }

    // MARK: - Factory
    public func createNewSound(
        soundId: String = UUID().uuidString,
        roomId: String,
        name: String = "Untitled Preset",
        preset: (BinauralSound) -> Void = { _ in }
    ) {
        let realm = try! Realm()
        try? realm.write {
            let s = BinauralSound()
            s.id = roomId
            s.roomId = roomId
            s.name = name
            s.lastUpdatedBy = currentUserId
            preset(s)
            realm.add(s, update: .modified)
        }
    }
}
