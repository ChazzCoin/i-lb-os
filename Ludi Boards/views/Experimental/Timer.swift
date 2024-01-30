//
//  Timer.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/5/23.
//

import Foundation
import SwiftUI
import Combine

struct CountdownTimerView: View {
    @StateObject private var viewModel = CountdownTimerViewModel()

    var body: some View {
        Section {
            Text("Remaining Time: \(viewModel.remainingTime)")
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .center)
        }

        Section {
            Picker("Duration", selection: $viewModel.selectedDuration) {
                ForEach(1..<60*60, id: \.self) { seconds in
                    Text("\(seconds / 60) min \(seconds % 60) sec").tag(TimeInterval(seconds))
                }
            }
        }

        Section {
            Button("Start Countdown") {
                viewModel.startTimer()
            }
            .tint(.green)

            Button("Stop Countdown") {
                viewModel.stopTimer()
            }
            .tint(.red)
        }
    }
}

class CountdownTimerViewModel: ObservableObject {
    @Published var remainingTime: String = "00:00:00"
    @Published var selectedDuration = TimeInterval(60) // Default 1 minute
    private var timer: Timer?
    private var endTime: Date?
    var shouldKill = false

    func startTimer() {
        endTime = Date().addingTimeInterval(selectedDuration)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        resetRemainingTime()
    }

    private func updateRemainingTime() {
        if let endTime = endTime {
            let remaining = endTime.timeIntervalSince(Date())
            if remaining <= 0 {
                stopTimer()
                resetRemainingTime()
            } else {
                formatTime(remaining)
            }
        }
    }

    private func resetRemainingTime() {
        formatTime(selectedDuration)
    }

    private func formatTime(_ interval: TimeInterval) {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        remainingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


