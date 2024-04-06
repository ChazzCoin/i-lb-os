import SwiftUI

public class CoreEngine {
    public static func checkEngineCore() -> String {
        return "Engine Core Online!"
    }
}


public func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}


//

public extension Comparable {
    func bound(minValue: Self, maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}

public extension Double {
    func bound(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

public struct BouncingValue {
    var value: Double
    let min: Double
    let max: Double
    private var incrementing = true
    private let step: Double

    public init(initialValue: Double, min: Double, max: Double, step: Double = 0.1) {
        self.value = initialValue
        self.min = min
        self.max = max
        self.step = step
    }

    public mutating func update() -> Double {
        if incrementing {
            if value < max {
                value += step
            } else {
                incrementing = false
                value -= step
            }
        } else {
            if value > min {
                value -= step
            } else {
                incrementing = true
                value += step
            }
        }
        return value
    }
}
