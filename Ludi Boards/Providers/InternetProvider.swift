//
//  InternetProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/8/24.
//

import Foundation
import Network
import SwiftUI
import FirebaseStorage

class ConnectionTester {
    static func checkConnection(completion: @escaping (Double) -> Void) {
        // 1. Check network reachability
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // 2. Perform Ping Test for latency measurement
                performPingTest { latencyScore in
                    // 3. Perform Speed Test
                    performSpeedTest { speedScore in
                        // 4. Calculate overall score
                        let overallScore = calculateOverallScore(latencyScore: latencyScore, speedScore: speedScore)
                        // 5. Convert to percentage
                        let percentage = convertScoreToPercentage(overallScore)
                        completion(percentage)
                    }
                }
            } else {
                completion(0.0) // Not connected
            }
        }

        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    private static func performPingTest(completion: @escaping (Double) -> Void) {
        let host = NWEndpoint.Host("8.8.8.8") // Google DNS for example
        let port = NWEndpoint.Port(rawValue: 53)! // DNS port

        let connection = NWConnection(host: host, port: port, using: .tcp)

        let startTime = Date()
        connection.start(queue: .global())

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let endTime = Date()
                let latency = endTime.timeIntervalSince(startTime)
                completion(latency) // Returns latency in seconds
                connection.cancel()
            case .failed, .cancelled:
                completion(Double.infinity) // Indicates an error or no connection
            default:
                break
            }
        }
    }

    private static func performSpeedTest(completion: @escaping (Double) -> Void) {
        // Firebase Storage URL of the test file
        let testFileURLString = "https://firebasestorage.googleapis.com/v0/b/ludi-software.appspot.com/o/speedtest%2Fspeeder2.png?alt=media&token=c864d498-bfb0-4bb7-80f0-c54b111bff3c"

        guard let _ = URL(string: testFileURLString) else {
            completion(0.0)
            return
        }

        let startTime = Date()
        
        // Create a Firebase Storage reference
        let storageRef = Storage.storage().reference(forURL: testFileURLString)
        
        // Start downloading the file
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            guard let data = data, error == nil else {
                completion(0.0)
                return
            }

            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            let dataSize = Double(data.count) // Size in bytes

            // Speed in bytes per second
            let speed = dataSize / duration

            // Convert speed to Megabits per second
            let speedInMbps = (speed * 8) / 1_000_000

            completion(speedInMbps)
        }
    }


    private static func calculateOverallScore(latencyScore: Double, speedScore: Double) -> Double {
        // Define maximum expected latency (in milliseconds) and speed (in Mbps) for scaling
        let maxExpectedLatency: Double = 500  // example value, adjust as needed
        let maxExpectedSpeed: Double = 100    // example value, adjust as needed

        // Normalize latency and speed scores (assuming lower latency is better)
        let normalizedLatencyScore = max(0, 1 - (latencyScore / maxExpectedLatency))
        let normalizedSpeedScore = min(speedScore / maxExpectedSpeed, 1)

        // You can adjust weights if needed
        let latencyWeight = 0.4  // weight for latency
        let speedWeight = 0.6    // weight for speed

        // Calculate overall score (weighted average)
        let overallScore = (normalizedLatencyScore * latencyWeight) + (normalizedSpeedScore * speedWeight)

        // Scale score to 0-100 range
        return overallScore * 100
    }


    private static func convertScoreToPercentage(_ score: Double) -> Double {
        return min(max(score, 0.0), 100.0)
    }

}

// Usage remains similar as in the previous example


func checkInternetConnection(completion: @escaping (Double) -> Void) {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            // Assuming a basic connection is 50% (as we're not measuring actual speed)
            completion(50.0)
        } else {
            // Not connected
            completion(0.0)
        }
    }

    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
}

// Example usage in SwiftUI
struct InternetSpeedChecker: View {
    @State private var connectionStrength = 0.0

    var body: some View {
        
        HStack {
            Text("Strength: \(String(format: "%.2f", connectionStrength))%")
            WirelessSignalStrengthBars(strength: connectionStrength)
        }
        .frame(maxWidth: .infinity)
        .onTapAnimation {
            connectionStrength = 0.0000000
            ConnectionTester.checkConnection() { strength in
                DispatchQueue.main.async {
                    connectionStrength = strength
                }
            }
        }
        .onAppear {
            ConnectionTester.checkConnection() { strength in
                DispatchQueue.main.async {
                    connectionStrength = strength
                }
            }
        }
    }
}

struct WirelessSignalStrengthBars: View {
    var strength: Double
    @State var barHeight = 30.0
    private let totalBars = 10

    private func barHeight(index: Int) -> CGFloat {
        // Calculate height of each bar based on connection strength
        let threshold = (Double(index + 1) / Double(totalBars)) * 100.0
        return strength >= threshold ? CGFloat(20 + index * 10) : 20.0
    }

    private func barColor(index: Int) -> Color {
        let threshold = (Double(index + 1) / Double(totalBars)) * 100.0
        if strength >= threshold {
            if index < 3 {
                return .red // First 3 bars
            } else if index < 7 {
                return .yellow // Next 4 bars
            } else {
                return .green // Last 3 bars
            }
        } else {
            return .gray // Unfilled bars
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalBars, id: \.self) { index in
                Rectangle()
                    .frame(width: 8, height: barHeight)
                    .foregroundColor(barColor(index: index))
            }
        }
    }
}

struct WifiSignalChecker: View {
    @State private var wifiStrength = 0.0

    var body: some View {
        HStack {
            Text("Wifi Signal")
            WirelessSignalStrengthBars(strength: wifiStrength)
            
            
        }.onAppear() {
            wifiStrength = Double.random(in: 1...5)
        }
    }
}


struct WifiSignalChecker_Previews: PreviewProvider {
    static var previews: some View {
        WifiSignalChecker()
    }
}


struct WifiConnectionIndicator: View {
    @State private var isConnectedToWifi = false

    var body: some View {
        VStack {
            Image(systemName: isConnectedToWifi ? "wifi" : "wifi.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(isConnectedToWifi ? .green : .red)

            Text(isConnectedToWifi ? "Connected to Wi-Fi" : "Not Connected to Wi-Fi")
                .padding()
        }
        .onAppear(perform: checkWifiConnection)
    }

    private func checkWifiConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                isConnectedToWifi = path.usesInterfaceType(.wifi)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}

