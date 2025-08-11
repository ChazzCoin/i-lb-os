import SwiftUI

// MARK: - Compact Alignment Picker (centers + sacred/alignment beats → L/R)
// Usage:
// @State var left = 196.0, right = 204.0
// AlignmentHemiSyncPickerCompact(leftHz: $left, rightHz: $right)

public struct AlignCenter: Identifiable, Hashable { public let id = UUID(); public let name: String; public let hz: Double }
public struct AlignBeat: Identifiable, Hashable { public let id = UUID(); public let name: String; public let hz: Double }

// Alignment / sacred-geometry carriers (centers)
private let alignmentCenters: [AlignCenter] = [
    // All centers chosen so integer-part digital root ∈ {3,6,9}
    .init(name: "×0.3 • 108 Hz", hz: 108),   // 1+0+8=9
    .init(name: "×0.35 • 126 Hz", hz: 126),  // 1+2+6=9
    .init(name: "×0.4 • 144 Hz", hz: 144),   // 9
    .init(name: "×0.45 • 162 Hz", hz: 162),  // 9
    .init(name: "Solfeggio • 174 Hz", hz: 174),  // 3
    .init(name: "×0.5 • 180 Hz", hz: 180),   // 9
    .init(name: "×0.6 • 216 Hz", hz: 216),   // 9
    .init(name: "×0.7 • 252 Hz", hz: 252),   // 9
    .init(name: "×0.75 • 270 Hz", hz: 270),  // 9
    .init(name: "×0.8 • 288 Hz", hz: 288),   // 9
    .init(name: "×0.85 • 306 Hz", hz: 306),  // 9
    .init(name: "×0.9 • 324 Hz", hz: 324),   // 9
    .init(name: "×1.0 • 360 Hz", hz: 360),   // 9
    .init(name: "A432 • D360×1.2", hz: 432),     // 9
    .init(name: "Solfeggio • 444 Hz", hz: 444),  // 3
    .init(name: "Solfeggio • 528 Hz", hz: 528),  // 6
    .init(name: "×1.6 • 576 Hz", hz: 576),   // 9
    .init(name: "×1.8 • 648 Hz", hz: 648),   // 9
    .init(name: "×2.0 • 720 Hz", hz: 720),   // 9
    .init(name: "×2.4 • 864 Hz", hz: 864),   // 9
]

// Alignment-only binaural beats (D360 divisors / sacred picks)
public let alignmentBeats: [AlignBeat] = [
    .init(name: "Tetrahedral: 2.5Hz", hz: 2.5),
    .init(name: "Earth: 3.0Hz", hz: 3.0),
    .init(name: "Merkaba: 4.0Hz", hz: 4.0),
    .init(name: "Golden Ratio: 5.0Hz", hz: 5.0),
    .init(name: "Harmonic: 6.0Hz", hz: 6.0),
    .init(name: "Pyramid Focus: 7.5Hz", hz: 7.5),
    .init(name: "Schumann: 7.83Hz", hz: 7.83),
    .init(name: "Platonic: 9.0Hz", hz: 9.0),
    .init(name: "Solar: 10Hz", hz: 10.0),
    .init(name: "Icosa/Dodeca: 12Hz", hz: 12.0),
    .init(name: "Harmonic: 15Hz", hz: 15.0),
    .init(name: "Double Schumann: 15.66Hz", hz: 15.66),
    .init(name: "Icosahedral: 18Hz", hz: 18.0),
    .init(name: "High Focus: 20Hz", hz: 20.0),
    .init(name: "Cube-Octa: 30Hz", hz: 30.0),
    .init(name: "Integration: 40Hz", hz: 40.0),
    .init(name: "Merkaba High: 45Hz", hz: 45.0),
]

struct HemiSyncBeatPicker: View {
    @Binding var beat: AlignBeat
    let alignmentBeats: [AlignBeat]

    @State private var showPicker = false
    @State private var query = ""

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Label("Hemi-Sync Frequency", systemImage: "waveform.circle.fill")
                .font(.headline)
                .labelStyle(.titleAndIcon)

//                Spacer()

            // Large, finger-friendly “pill” button showing current selection
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                showPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(beat.name)
                        .lineLimit(1)

                    Text("\(beat.hz, specifier: "%.2f") Hz")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .buttonStyle(.plain)
            .accessibilityLabel("Beat")
            .accessibilityValue("\(beat.name), \(beat.hz, specifier: "%.2f") hertz")
        
                
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                List {
                    ForEach(filteredBeats) { b in
                        Button {
                            beat = b
                            UISelectionFeedbackGenerator().selectionChanged()
                            showPicker = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(b.name)
                                        .font(.body)
                                    Text("\(b.hz, specifier: "%.2f") Hz")
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if b.id == beat.id {
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .tint(.primary)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Select Beat")
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showPicker = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(24)
        }
    }

    private var filteredBeats: [AlignBeat] {
        guard !query.isEmpty else { return alignmentBeats }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return alignmentBeats.filter {
            $0.name.localizedCaseInsensitiveContains(q)
            || String(format: "%.2f", $0.hz).contains(q)
        }
    }
}

public struct AlignmentHemiSyncPickerCompact: View {
    // External bindings — caller owns synthesis; we compute L/R here
    @Binding var leftHz: Double
    @Binding var rightHz: Double

    // Bounds for comfortable carriers
    var minEarHz: Double = 20
    var maxEarHz: Double = 1200

    // Internal state
    @State private var center: AlignCenter = alignmentCenters[5]   // default 432 Hz
    @State private var beat: AlignBeat = alignmentBeats[5]         // default 7.83 Hz
    @State private var constrain = true

    public init(leftHz: Binding<Double>, rightHz: Binding<Double>, minEarHz: Double = 20, maxEarHz: Double = 1200) {
        self._leftHz = leftHz
        self._rightHz = rightHz
        self.minEarHz = minEarHz
        self.maxEarHz = maxEarHz
    }

    public var body: some View {
        VStack(spacing: 12) {
            
            // Center choice (carrier)
            HemiSyncBeatPicker(beat: $beat, alignmentBeats: alignmentBeats)

            // Beat choice (binaural)
            VStack(alignment: .center) {
                HStack {
                    Label("Range", systemImage: "waveform.circle")
                    Spacer()
                    Picker("Center", selection: $center) {
                        ForEach(alignmentCenters) { c in
                            HStack { Text(c.name); Spacer(); Text(String(format: "%.0f Hz", c.hz)).foregroundStyle(.secondary) }.tag(c)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            // Live readout
            HStack(spacing: 8) {
                readout("Left", leftHz)
                readout("Right", rightHz)
                readout("Binural", abs(rightHz - leftHz))
            }

        }
        .onChange(of: center, perform: { _ in
            apply(centerHz: center.hz, beatHz: beat.hz)
        })
        .onChange(of: beat, perform: { _ in
            apply(centerHz: center.hz, beatHz: beat.hz)
        })
        .onChange(of: leftHz, perform: { _ in
            center = nearestCenter(to: (leftHz + rightHz) / 2)
            beat = nearestBeat(to: abs(rightHz - leftHz))
            // Ensure initial L/R are aligned
            apply(centerHz: center.hz, beatHz: beat.hz)
        })
        .onChange(of: rightHz, perform: { _ in
            center = nearestCenter(to: (leftHz + rightHz) / 2)
            beat = nearestBeat(to: abs(rightHz - leftHz))
            // Ensure initial L/R are aligned
            apply(centerHz: center.hz, beatHz: beat.hz)
        })
//        .padding(16)
        .background(.clear)
        .onAppear {
            // Initialize from current bindings using nearest alignment center/beat
            center = nearestCenter(to: (leftHz + rightHz) / 2)
            beat = nearestBeat(to: abs(rightHz - leftHz))
            // Ensure initial L/R are aligned
            apply(centerHz: center.hz, beatHz: beat.hz)
        }
    }

    // MARK: - UI bits
    private func readout(_ title: String, _ value: Double) -> some View {
        VStack(spacing: 1) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(String(format: "%.2f Hz", value)).monospaced().font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(3)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    private func readout(_ value: Double) -> some View {
        VStack(spacing: 1) {
            Text(String(format: "%.2f Hz", value)).monospaced().font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(3)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Logic
    private func apply(centerHz: Double, beatHz: Double) {
        var c = centerHz
        var b = max(0, beatHz)
        // Keep symmetric around center by default
        var L = c - b/2
        var R = c + b/2

        if constrain {
            // If out of audible range, shift center minimally to keep symmetry
            if L < minEarHz { c = minEarHz + b/2; L = c - b/2; R = c + b/2 }
            if R > maxEarHz { c = maxEarHz - b/2; L = c - b/2; R = c + b/2 }
            // Final clamp (in case b is huge)
            L = max(minEarHz, min(L, maxEarHz))
            R = max(minEarHz, min(R, maxEarHz))
        }
        leftHz = L; rightHz = R
    }

    private func nearestCenter(to value: Double) -> AlignCenter {
        alignmentCenters.min(by: { abs($0.hz - value) < abs($1.hz - value) }) ?? alignmentCenters[0]
    }
    private func nearestBeat(to value: Double) -> AlignBeat {
        alignmentBeats.min(by: { abs($0.hz - value) < abs($1.hz - value) }) ?? alignmentBeats[0]
    }
}

// MARK: - Preview
struct AlignmentHemiSyncPickerCompact_Previews: PreviewProvider {
    struct Demo: View {
        @State var left = 196.0
        @State var right = 204.0
        var body: some View {
            VStack(spacing: 20) {
                AlignmentHemiSyncPickerCompact(leftHz: $left, rightHz: $right)
                VStack(alignment: .leading) {
                    Text("Bind to your synth engine:").font(.footnote).foregroundStyle(.secondary)
                    Text("Left  → \(String(format: "%.2f", left)) Hz")
                    Text("Right → \(String(format: "%.2f", right)) Hz")
                }
            }
            .padding()
        }
    }
    static var previews: some View { Demo() }
}
