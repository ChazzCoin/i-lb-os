enum Formation: String, CaseIterable {
    case f433 = "4-3-3", f442 = "4-4-2", f352 = "3-5-2"
    var rows: [Int] {
        switch self {
        case .f433: return [1, 4, 3, 3]
        case .f442: return [1, 4, 4, 2]
        case .f352: return [1, 3, 5, 2]
        }
    }
}

func stamp(_ f: Formation, in rect: CGRect) -> [CGPoint] {
    let rows = f.rows
    return rows.enumerated().flatMap { col, n -> [CGPoint] in
        let x = rect.minX + rect.width
            * (CGFloat(col) + 0.5) / CGFloat(rows.count)
        return (0..<n).map { i in
            CGPoint(x: x, y: rect.minY + rect.height
                * (CGFloat(i) + 0.5) / CGFloat(n))
        }
    }
}

let spots = stamp(.f433, in: pitchRect)