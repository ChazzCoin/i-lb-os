
import Foundation
import SwiftUI

// Master
public class Sports {
    public let sol = SolBoards()
    public let soccer = Soccer()
    public let basketball = Basketball()
    public let football = Football()
    public let pool = Pool()
    
    public func getAllBoardsBySport() -> [String:[String: () -> AnyView]] {
        var temp: [String:[String: () -> AnyView]] = [:]
        temp[sol.sport] = sol.boards
        temp[soccer.sport] = soccer.boards
        temp[basketball.sport] = basketball.boards
        temp[football.sport] = football.boards
        temp[pool.sport] = pool.boards
        return temp
    }
    public func getAllBoards() -> [String: () -> AnyView] {
        let boardCategories = [sol.boards, soccer.boards, basketball.boards, football.boards, pool.boards]
        return boardCategories.reduce(into: [String: () -> AnyView]()) { result, boards in
            result.merge(boards) { (current, _) in current }
        }
    }
    public func getAllMinis() -> [String: () -> AnyView] {
        let boardCategories = [sol.minis, soccer.minis, basketball.minis, football.minis, pool.minis]
        return boardCategories.reduce(into: [String: () -> AnyView]()) { result, boards in
            result.merge(boards) { (current, _) in current }
        }
    }

}

public struct SolBackground : View {
    @State public var isMini: Bool
    
    public var body: some View {
        Image("sol_bg_trans")
            .resizable()
            .frame(width: isMini ? 100: 5000, height: isMini ? 100 : 5000)
    }
}

public class SolBoards: SportBoard {
    public var sport: String = "SOL"
    public var boards: [String: () -> AnyView] = [
        "Sol": { AnyView(SolBackground(isMini: false)) }
    ]
    public var minis: [String: () -> AnyView] = [
        "Sol": { AnyView(SolBackground(isMini: true)) }
    ]
}

// Individual Sports
public class Soccer : SportBoard {
    public var sport: String = "Soccer"
    public var boards: [String: () -> AnyView] = [
        // Redesign vector pitch (RD-2 / TASK-003). Becomes the redesign board's
        // default at the RD-6 cutover; selectable now without changing shipping.
        "Soccer Redesign Full View": { AnyView(RedesignSoccerBoardView(isMini: false, half: false)) },
        "Soccer Redesign Half View": { AnyView(RedesignSoccerBoardView(isMini: false, half: true)) },
        "Soccer Field Full View": { AnyView(SoccerFieldFullView(isMini: false)) },
        "Soccer Field Half View": { AnyView(SoccerFieldHalfView(isMini: false)) },
        "Soccer Field 1": getImageBoard(imageName: "soccer_one", isMini: false),
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: false)
    ]
    public var minis: [String: () -> AnyView] = [
        "Soccer Redesign Full View": { AnyView(RedesignSoccerBoardView(isMini: true, half: false)) },
        "Soccer Redesign Half View": { AnyView(RedesignSoccerBoardView(isMini: true, half: true)) },
        "Soccer Field Full View": { AnyView(SoccerFieldFullView(isMini: true)) },
        "Soccer Field Half View": { AnyView(SoccerFieldHalfView(isMini: true)) },
        "Soccer Field 1": getImageBoard(imageName: "soccer_one", isMini: true),
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: true)
    ]
}
public class Basketball : SportBoard {
    public var sport: String = "Basketball"
    public var boards: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: false),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: false),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: false),
    ]
    public var minis: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: true),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: true),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: true),
    ]
}
public class Football : SportBoard {
    public var sport: String = "Football"
    public var boards: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: true)) },
    ]
}
public class Pool : SportBoard {
    public var sport: String = "Pool"
    public var boards: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: false),
    ]
    public var minis: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: true),
    ]
}

// Protocol/Interface
public protocol SportBoard {
    var sport: String { get set }
    var boards: [String: () -> AnyView] { get set }
    var minis: [String: () -> AnyView] { get set }
}

// Helpers
public func getImageBoard(imageName: String, isMini: Bool) -> () -> AnyView {
    {AnyView(ImageBgView(image: imageName, isMini: isMini))}
}
