//
//  Controllers.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 8/9/25.
//

import SwiftUI

// MARK: - Precision numeric TextField with formatter and bounds
struct PrecisionField: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let decimals: Int
    let unit: String?
    var disabled: Bool = false
    
    @State private var text: String = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        TextField(title, text: Binding(
            get: { formatted(value) },
            set: { new in
                text = new
                if let d = Double(new.replacingOccurrences(of: ",", with: "")) {
                    value = min(max(d, range.lowerBound), range.upperBound)
                }
            })
        )
        .keyboardType(.decimalPad)
        .textFieldStyle(.roundedBorder)
        .font(.system(.callout, design: .monospaced))
        .frame(minWidth: 90)
        .disabled(disabled)
        .focused($focused)
        .onTapGesture { focused = true }
        .overlay(alignment: .trailing) {
            if let unit {
                Text(unit)
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    .padding(.trailing, 6)
            }
        }
        .onChange(of: value) { _ in
            if !focused { text = formatted(value) }
        }
        .onAppear { text = formatted(value) }
    }
    private func formatted(_ v: Double) -> String {
        String(format: "%.\(decimals)f", v)
    }
}

struct PrecisionControl: View {
    let label: String
    let icon: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var coarseStep: Double = 1
    var fineStep: Double = 0.1
    var decimals: Int = 2
    var unit: String? = "Hz"
    var disabled: Bool = false
    var sliderIsLog: Bool = false

    @State private var currentFine: Double = 0.1
    @State private var currentCoarse: Double = 1.0
    @State private var isSliding = false

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                Spacer()
                Text("\(value, specifier: "%.\(decimals)f")\(unit.map { " \($0)" } ?? "")")
                    .font(.caption).foregroundStyle(.secondary).monospacedDigit()
            }

            HStack(spacing: 10) {
                Group {
                    if sliderIsLog {
                        // unchanged; continuous by design
                        LogSlider(value: $value, range: range)
                            .disabled(disabled)
                    } else {
                        // Continuous slider, manual quantize when sliding ends
                        Slider(
                            value: Binding(
                                get: { value },
                                set: { newVal in
                                    value = clamp(newVal, to: range)
                                }
                            ),
                            in: range,
                            onEditingChanged: { sliding in
                                isSliding = sliding
                                if !sliding {
                                    value = quantize(value, step: currentCoarse, within: range)
                                }
                            }
                        )
                        .disabled(disabled)
                    }
                }

                PrecisionField(title: label, value: $value, range: range,
                               decimals: decimals, unit: unit, disabled: disabled)
                    .frame(width: 120)
            }

            HStack(spacing: 8) {
                // fine nudge
                HStack(spacing: 4) {
//                    Button { value = quantize(clamp(value - currentFine, to: range),
//                                              step: currentFine, within: range) } label {
//                        Image(systemName: "minus.circle")
//                    }
//                    Button { value = quantize(clamp(value + currentFine, to: range),
//                                              step: currentFine, within: range) } label {
//                        Image(systemName: "plus.circle")
//                    }
                }
                .buttonStyle(.bordered)
                .disabled(disabled)

                Menu {
                    Picker("Fine step", selection: $currentFine) {
                        Text("0.001").tag(0.001 as Double)
                        Text("0.01").tag(0.01 as Double)
                        Text("0.1").tag(0.1 as Double)
                        Text("1").tag(1.0 as Double)
                    }
                    Picker("Coarse step", selection: $currentCoarse) {
                        Text("0.1").tag(0.1 as Double)
                        Text("1").tag(1.0 as Double)
                        Text("5").tag(5.0 as Double)
                        Text("10").tag(10.0 as Double)
                    }
                } label: {
                    Label("Step", systemImage: "dial.low")
                }
                .disabled(disabled)

                Spacer()
            }
            .font(.caption)
        }
        .onAppear {
            currentFine   = max(fineStep,   0.000_001)
            currentCoarse = max(coarseStep, 0.000_001)
            value = clamp(value, to: range) // guard initial
        }
        .onChange(of: coarseStep) { v in currentCoarse = max(v, 0.000_001) }
        .onChange(of: fineStep)   { v in currentFine   = max(v, 0.000_001) }
    }

    // MARK: - utils
    private func clamp(_ v: Double, to r: ClosedRange<Double>) -> Double {
        min(max(v, r.lowerBound), r.upperBound)
    }
    private func quantize(_ v: Double, step: Double, within r: ClosedRange<Double>) -> Double {
        let s = max(step, 0.000_001)
        let q = (v / s).rounded() * s
        return clamp(q, to: r)
    }
}



// MARK: - Duration mm:ss with total seconds binding
struct DurationField: View {
    @Binding var seconds: Double
    var disabled: Bool = false
    
    @State private var mm: String = "10"
    @State private var ss: String = "00"
    
    var body: some View {
        HStack {
            Label("Duration", systemImage: "clock")
            Spacer()
            HStack(spacing: 6) {
                TextField("mm", text: Binding(
                    get: { mm },
                    set: { mm = $0.filter { $0.isNumber }.prefix(3).description; apply() }
                ))
                .keyboardType(.numberPad)
                .frame(width: 44)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .disabled(disabled)
                
                Text(":")
                
                TextField("ss", text: Binding(
                    get: { ss },
                    set: { ss = $0.filter { $0.isNumber }.prefix(2).description; apply() }
                ))
                .keyboardType(.numberPad)
                .frame(width: 36)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .disabled(disabled)
                
                Text("\(Int(seconds))s")
                    .font(.caption).foregroundStyle(.secondary).monospacedDigit()
            }
        }
        .onAppear { load() }
        .onChange(of: seconds) { _ in load() }
    }
    private func load() {
        let total = Int(seconds)
        mm = String(total / 60)
        ss = String(format: "%02d", total % 60)
    }
    private func apply() {
        let m = Int(mm) ?? 0
        let s = min(max(Int(ss) ?? 0, 0), 59)
        seconds = Double(m * 60 + s)
    }
}

// MARK: - Note snapping utilities
struct NoteSnapper: View {
    @Binding var freq: Double
    @Binding var snapEnabled: Bool
    @Binding var aRef: Double // 440 or 432
    
    var disabled: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            Toggle(isOn: $snapEnabled) {
                Label("Snap to note", systemImage: "music.note")
            }
            .toggleStyle(.switch)
            .disabled(disabled)
            
            Picker("", selection: $aRef) {
                Text("A=440").tag(440.0)
                Text("A=432").tag(432.0)
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
            .disabled(disabled || !snapEnabled)
            
            Button {
                guard snapEnabled else { return }
                freq = nearestNoteFrequency(to: freq, aRef: aRef)
            } label: {
                Label("Snap Now", systemImage: "target")
            }
            .buttonStyle(.bordered)
            .disabled(disabled || !snapEnabled)
        }
        .font(.caption)
    }
    
    private func nearestNoteFrequency(to f: Double, aRef: Double) -> Double {
        // MIDI 69 = A4
        let n = round(69 + 12 * log2(f / aRef))
        return aRef * pow(2, (n - 69) / 12)
    }
}

// MARK: - Logarithmic slider (for very wide ranges)
struct LogSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        // map to 0..1 space logarithmically
        Slider(value: Binding(
            get: { norm(logValue(value)) },
            set: { t in value = expValue(denorm(t)) }
        ))
    }
    private func logValue(_ x: Double) -> Double {
        let a = log(range.lowerBound)
        let b = log(range.upperBound)
        return (log(x) - a) / (b - a)
    }
    private func expValue(_ t: Double) -> Double {
        let a = log(range.lowerBound)
        let b = log(range.upperBound)
        return exp(a + (b - a) * t)
    }
    private func norm(_ x: Double) -> Double { min(max(x, 0), 1) }
    private func denorm(_ t: Double) -> Double { min(max(t, 0), 1) }
}
