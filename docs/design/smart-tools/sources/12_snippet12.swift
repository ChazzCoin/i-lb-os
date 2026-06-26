func grid(cols: Int, rows: Int,
          in rect: CGRect) -> [CGPoint] {
    (0..<rows).flatMap { r in
        (0..<cols).map { c in
            CGPoint(
                x: rect.minX + rect.width
                    * (CGFloat(c) + 0.5) / CGFloat(cols),
                y: rect.minY + rect.height
                    * (CGFloat(r) + 0.5) / CGFloat(rows))
        }
    }
}

// 4×3 rondo grid
let cells = grid(cols: 4, rows: 3, in: boardRect)