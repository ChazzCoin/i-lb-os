
import Foundation
import SwiftUI

// Master
public class Sports {
    public let sol = SolBoards()
    public let soccer = Soccer()
    public let basketball = Basketball()
    public let football = Football()
    public let pool = Pool()
    // Vector sport boards imported from the Sports Boards Catalogue. New sports
    // that had no prior board get their own registry class here.
    public let futsal = Futsal()
    public let baseball = Baseball()
    public let tennis = Tennis()
    public let volleyball = Volleyball()
    public let handball = Handball()
    public let hockey = Hockey()

    /// All sport board-providers, in display order. Single source the three
    /// aggregators below iterate, so a new sport is wired by adding it once.
    private var allSports: [SportBoard] {
        [sol, soccer, basketball, football, pool,
         futsal, baseball, tennis, volleyball, handball, hockey]
    }

    public func getAllBoardsBySport() -> [String:[String: () -> AnyView]] {
        var temp: [String:[String: () -> AnyView]] = [:]
        for s in allSports { temp[s.sport] = s.boards }
        return temp
    }
    public func getAllBoards() -> [String: () -> AnyView] {
        allSports.map { $0.boards }.reduce(into: [String: () -> AnyView]()) { result, boards in
            result.merge(boards) { (current, _) in current }
        }
    }
    public func getAllMinis() -> [String: () -> AnyView] {
        allSports.map { $0.minis }.reduce(into: [String: () -> AnyView]()) { result, boards in
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
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: false),
        "Soccer Markings Full View": { AnyView(SoccerMarkingsBoardView(isMini: false)) }
    ]
    public var minis: [String: () -> AnyView] = [
        "Soccer Redesign Full View": { AnyView(RedesignSoccerBoardView(isMini: true, half: false)) },
        "Soccer Redesign Half View": { AnyView(RedesignSoccerBoardView(isMini: true, half: true)) },
        "Soccer Field Full View": { AnyView(SoccerFieldFullView(isMini: true)) },
        "Soccer Field Half View": { AnyView(SoccerFieldHalfView(isMini: true)) },
        "Soccer Field 1": getImageBoard(imageName: "soccer_one", isMini: true),
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: true),
        "Soccer Markings Full View": { AnyView(SoccerMarkingsBoardView(isMini: true)) }
    ]
}
public class Basketball : SportBoard {
    public var sport: String = "Basketball"
    public var boards: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: false),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: false),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: false),
        "Basketball Court Full View": { AnyView(CourtBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: true),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: true),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: true),
        "Basketball Court Full View": { AnyView(CourtBoardView(isMini: true)) },
    ]
}
public class Football : SportBoard {
    public var sport: String = "Football"
    public var boards: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: false)) },
        "Football Gridiron Full View": { AnyView(GridironBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: true)) },
        "Football Gridiron Full View": { AnyView(GridironBoardView(isMini: true)) },
    ]
}
public class Pool : SportBoard {
    public var sport: String = "Pool"
    public var boards: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: false),
        "Pool Table Vector": { AnyView(PoolTableBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: true),
        "Pool Table Vector": { AnyView(PoolTableBoardView(isMini: true)) },
    ]
}

// Sports introduced by the Sports Boards Catalogue (no prior board provider).
public class Futsal : SportBoard {
    public var sport: String = "Futsal"
    public var boards: [String: () -> AnyView] = [
        "Futsal Court": { AnyView(FutsalBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Futsal Court": { AnyView(FutsalBoardView(isMini: true)) },
    ]
}
public class Baseball : SportBoard {
    public var sport: String = "Baseball"
    public var boards: [String: () -> AnyView] = [
        "Baseball Diamond": { AnyView(DiamondBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Baseball Diamond": { AnyView(DiamondBoardView(isMini: true)) },
    ]
}
public class Tennis : SportBoard {
    public var sport: String = "Tennis"
    public var boards: [String: () -> AnyView] = [
        "Tennis Court": { AnyView(TennisBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Tennis Court": { AnyView(TennisBoardView(isMini: true)) },
    ]
}
public class Volleyball : SportBoard {
    public var sport: String = "Volleyball"
    public var boards: [String: () -> AnyView] = [
        "Volleyball Court": { AnyView(VolleyBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Volleyball Court": { AnyView(VolleyBoardView(isMini: true)) },
    ]
}
public class Handball : SportBoard {
    public var sport: String = "Handball"
    public var boards: [String: () -> AnyView] = [
        "Handball Court": { AnyView(HandballBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Handball Court": { AnyView(HandballBoardView(isMini: true)) },
    ]
}
public class Hockey : SportBoard {
    public var sport: String = "Hockey"
    public var boards: [String: () -> AnyView] = [
        "Ice Hockey Rink": { AnyView(RinkBoardView(isMini: false)) },
    ]
    public var minis: [String: () -> AnyView] = [
        "Ice Hockey Rink": { AnyView(RinkBoardView(isMini: true)) },
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
