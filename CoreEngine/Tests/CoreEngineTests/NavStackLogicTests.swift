//
//  NavStackLogicTests.swift
//  CoreEngineTests
//
//  Covers the pure-logic core of the NavStack engine-room fixes:
//  - CoreQueue gained LIFO (push/pop/top) without breaking FIFO.
//  - Back navigation is now LIFO (the CRITICAL FIFO-queue bug).
//  - WindowID normalizes casing exactly once.
//

import XCTest
@testable import CoreEngine

final class CoreQueueStackTests: XCTestCase {

    func testPushPopTopAreLIFO() {
        var q = CoreQueue<String>()
        q.push("a"); q.push("b"); q.push("c")
        XCTAssertEqual(q.top, "c")
        XCTAssertEqual(q.pop(), "c")
        XCTAssertEqual(q.top, "b")
        XCTAssertEqual(q.pop(), "b")
        XCTAssertEqual(q.pop(), "a")
        XCTAssertNil(q.pop())
        XCTAssertNil(q.top)
    }

    func testFifoStillWorks() {
        var q = CoreQueue<Int>()
        q.enqueue(1); q.enqueue(2); q.enqueue(3)
        XCTAssertEqual(q.peek(), 1)
        XCTAssertEqual(q.dequeue(), 1)
        XCTAssertEqual(q.dequeue(), 2)
        XCTAssertEqual(q.count, 1)
    }

    // Mirrors NavWindowController.navTo / goBack stack manipulation to
    // prove back navigation is LIFO. With the old FIFO queue, A->B->C
    // then goBack landed on B by luck and the next goBack went FORWARD
    // to C, oscillating forever with A unreachable.
    func testBackNavigationSequenceIsLIFO() {
        var backStack = CoreQueue<WindowID>()
        func navTo(_ id: String) {
            let key = WindowID(id)
            if backStack.top != key { backStack.push(key) }
        }
        func goBack() -> WindowID? {
            guard backStack.count > 1 else { return backStack.top }
            _ = backStack.pop()
            return backStack.top
        }
        navTo("A"); navTo("B"); navTo("C")
        XCTAssertEqual(backStack.top, WindowID("c"))
        XCTAssertEqual(goBack(), WindowID("b"))
        XCTAssertEqual(goBack(), WindowID("a"))
        XCTAssertEqual(goBack(), WindowID("a"), "goBack must refuse to pop the last remaining entry")
    }

    func testNavToSameViewDoesNotStackDuplicates() {
        var backStack = CoreQueue<WindowID>()
        func navTo(_ id: String) {
            let key = WindowID(id)
            if backStack.top != key { backStack.push(key) }
        }
        navTo("chat"); navTo("chat"); navTo("CHAT")
        XCTAssertEqual(backStack.count, 1, "re-navigating to the active view must not grow the stack")
    }
}

final class WindowIDTests: XCTestCase {

    func testLowercasesAtConstruction() {
        XCTAssertEqual(WindowID("MvSettings").rawValue, "mvsettings")
        XCTAssertEqual(WindowID("CHAT"), WindowID("chat"))
    }

    func testStringLiteralAndConvenience() {
        let a: WindowID = "Board Settings"
        XCTAssertEqual(a.rawValue, "board settings")
        XCTAssertEqual("Profile".windowID, WindowID("profile"))
    }

    // The whole point: a "mvSettings" sender and a "mvsettings" listener
    // must resolve to the same pool entry.
    func testUsableAsDictionaryKeyCaseInsensitively() {
        var pool: [WindowID: Int] = [:]
        pool[WindowID("Chat")] = 1
        XCTAssertEqual(pool[WindowID("chat")], 1)
        XCTAssertEqual(pool[WindowID("CHAT")], 1)
        XCTAssertNil(pool[WindowID("home")])
    }

    func testDescription() {
        XCTAssertEqual(WindowID("Xyz").description, "xyz")
    }
}
