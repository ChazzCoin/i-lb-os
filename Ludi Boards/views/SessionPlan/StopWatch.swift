//
//  StopWatch.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/4/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import FirebaseDatabase

struct StopwatchView: View {
    @StateObject var viewModel = StopwatchViewModel()
    
    var body: some View {
        LoadingForm(isLoading: .constant(false)) { loader in
            Text(viewModel.timeElapsed)
                .font(.system(size: 40, weight: .bold, design: .default))
                .padding()

            Button(action: {
                if viewModel.isRunning {
                    viewModel.stop()
                } else {
                    viewModel.start()
                }
            }) {
                Text(viewModel.isRunning ? "Stop" : "Start")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Button(action: {
                viewModel.reset()
            }) {
                Text("Reset")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
//        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .navigationBarTitle("Stop Watch", displayMode: .inline)
    }
}

class StopwatchViewModel: ObservableObject {
    @Published var timeElapsed: String = "00:00:00"
    private var startTime: Date?
    private var timer: Timer?
    private var elapsed: TimeInterval = 0
    @Published var isRunning: Bool = false
    
    @State var watch = Stopwatch()
    @State var hostId = UUID().uuidString
    @State var hostName = ""
    
    let realmIntance = realm()
    @State private var sessionNotificationToken: NotificationToken? = nil
    var reference: DatabaseReference = Database
        .database()
        .reference()
        .child(DatabasePaths.stopWatch.rawValue)
        .child("default-1")
    
    init() {
        watch.hostId = hostId
        observeWatch()
    }

    func start() {
        isRunning = true
        startTime = Date() - elapsed
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let startTime = self?.startTime else { return }
            let currentTime = Date()
            self?.elapsed = currentTime.timeIntervalSince(startTime)
            self?.updateTimeElapsed()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        stop()
        elapsed = 0
        updateTimeElapsed()
    }

    private func updateTimeElapsed() {
        let time = Int(elapsed)
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        let milliseconds = Int((elapsed.truncatingRemainder(dividingBy: 1)) * 100)

        timeElapsed = String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
        self.watch.timeElapsed = timeElapsed
        saveWatch()
    }
    
    func saveWatch() {
        reference.setValue(self.watch.toDict())
    }
    
    func observeWatch() {
        reference.fireObserver { snapshot in
            let temp = Stopwatch(dictionary: snapshot.toHashMap())
            if temp.hostId == self.hostId {
                return
            }
            self.timeElapsed = temp.timeElapsed
        }
    }
}
