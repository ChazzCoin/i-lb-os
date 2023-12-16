
import Foundation
import SwiftUI




// Master
class Sports {
    let soccer = Soccer()
    let basketball = Basketball()
    let football = Football()
    let pool = Pool()
    
    func getAllBoardsBySport() -> [String:[String: () -> AnyView]] {
        var temp: [String:[String: () -> AnyView]] = [:]
        temp[soccer.sport] = soccer.boards
        temp[basketball.sport] = basketball.boards
        temp[football.sport] = football.boards
        temp[pool.sport] = pool.boards
        return temp
    }
    func getAllBoards() -> [String: () -> AnyView] {
        let boardCategories = [soccer.boards, basketball.boards, football.boards, pool.boards]
        return boardCategories.reduce(into: [String: () -> AnyView]()) { result, boards in
            result.merge(boards) { (current, _) in current }
        }
    }
    func getAllMinis() -> [String: () -> AnyView] {
        let boardCategories = [soccer.minis, basketball.minis, football.minis, pool.minis]
        return boardCategories.reduce(into: [String: () -> AnyView]()) { result, boards in
            result.merge(boards) { (current, _) in current }
        }
    }

}

// Individual Sports
class Soccer : SportBoard {
    var sport: String = "Soccer"
    var boards: [String: () -> AnyView] = [
        "Soccer Field Full View": { AnyView(SoccerFieldFullView(isMini: false)) },
        "Soccer Field Half View": { AnyView(SoccerFieldHalfView(isMini: false)) },
        "Soccer Field 1": getImageBoard(imageName: "soccer_one", isMini: false),
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: false)
    ]
    var minis: [String: () -> AnyView] = [
        "Soccer Field Full View": { AnyView(SoccerFieldFullView(isMini: true)) },
        "Soccer Field Half View": { AnyView(SoccerFieldHalfView(isMini: true)) },
        "Soccer Field 1": getImageBoard(imageName: "soccer_one", isMini: true),
        "Soccer Field 2": getImageBoard(imageName: "soccer_two", isMini: true)
    ]
}
class Basketball : SportBoard {
    var sport: String = "Basketball"
    var boards: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: false),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: false),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: false),
    ]
    var minis: [String: () -> AnyView] = [
        "Basketball 1": getImageBoard(imageName: "basketball_one", isMini: true),
        "Basketball 2": getImageBoard(imageName: "basketball_two", isMini: true),
        "Basketball 3": getImageBoard(imageName: "basketball_three", isMini: true),
    ]
}
class Football : SportBoard {
    var sport: String = "Football"
    var boards: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: false)) },
    ]
    var minis: [String: () -> AnyView] = [
        "Football Field Full View": { AnyView(FootballFieldView(isMini: true)) },
    ]
}
class Pool : SportBoard {
    var sport: String = "Pool"
    var boards: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: false),
    ]
    var minis: [String: () -> AnyView] = [
        "Pool Table 1": getImageBoard(imageName: "pool_table", isMini: true),
    ]
}

// Protocol/Interface
protocol SportBoard {
    var sport: String { get set }
    var boards: [String: () -> AnyView] { get set }
    var minis: [String: () -> AnyView] { get set }
}

// Helpers
func getImageBoard(imageName: String, isMini: Bool) -> () -> AnyView {
    {AnyView(ImageBgView(image: imageName, isMini: isMini))}
}
