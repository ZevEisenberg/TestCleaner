import TestCleaner
import XCTest

struct ShouldNever: Error {
  init() {
    XCTFail("We should never construct this error during a successful test run")
  }
}

final class TestCleanerTests: XCTestCase {
  func testAssertBoolean() {
    assertBoolean(testCases: [
      Pair(true, true),
      Pair(false, false),
      xPair(false, true),
      xPair(true, false),
    ])
  }

  func testAssertBoolean_throws() {
    func doThrowingThing(andReturn result: Bool, throw: Bool = false) throws -> Bool {
      if `throw` {
        throw ShouldNever()
      }
      return result
    }
    assertBoolean(testCases: [
      Pair(try doThrowingThing(andReturn: true), try doThrowingThing(andReturn: true)),
      //       ^ error here...                       ^ ...and here
      Pair(try doThrowingThing(andReturn: false), try doThrowingThing(andReturn: false)),
      xPair(try doThrowingThing(andReturn: false, throw: true), try doThrowingThing(andReturn: true, throw: true)),
      xPair(try doThrowingThing(andReturn: true, throw: true), try doThrowingThing(andReturn: false, throw: true)),
    ])
  }

  func testAssertLessThan() {
    assertLessThan(testCases: [
      Pair(1, 2),
      Pair(-1, 3.6),
      xPair(10, 0),
      xPair(10, 10),
    ])
  }

  func testAssertGreaterThan() {
    assertGreaterThan(testCases: [
      Pair(2, 1),
      Pair(3.6, -1),
      xPair(0, 10),
      xPair(10, 10),
    ])
  }

  func testAssertLessThanOrEqual() {
    assertLessThanOrEqual(testCases: [
      Pair(1, 2),
      Pair(-1, 3.6),
      Pair(100, 100),
      xPair(10, 0),
      xPair(10, 10),
    ])
  }

  func testAssertGreaterThanOrEqual() {
    assertGreaterThanOrEqual(testCases: [
      Pair(2, 1),
      Pair(3.6, -1),
      Pair(100, 100),
      xPair(0, 10),
      xPair(10, 10),
    ])
  }

  func testAssertEqual() {
    assertEqual(testCases: [
      Pair("Hello", "Hello"),
      Pair("", ""),
      xPair("a", "b"),
    ])
  }

  func testAssertEqualWithAccuracy() {
    assertEqual(testCases: [
      Pair(1, 1.098),
      Pair(1, 0.98),
      Pair(2, 2.05),
      xPair(3, 3.11),
    ], accuracy: 0.1)
  }

  func testAssertNotEqual() {
    assertNotEqual(testCases: [
      Pair("Hello", "Aloha"),
      Pair("", "\n"),
      xPair("a", "a"),
    ])
  }

  func testAssertNotEqualWithAccuracy() {
    assertNotEqual(testCases: [
      Pair(1, 1.101),
      Pair(2, 1.8),
      xPair(3, 3),
    ], accuracy: 0.1)
  }

  func testAssertCustom() {
    // Assert that certain strings have the same count
    assertCustom(testCases: [
      Pair("One", "Two"),
      xPair("Three", "Four"),
    ], tests: { pair, file, line in
      XCTAssertEqual(try pair.left.count, try pair.right.count, file: file, line: line)
    })
  }

  func testLazyEvaluationForExclusion() {

    var calledInputs: [Int] = []

    func square(_ value: Int) -> Int {
      calledInputs.append(value)
      return value * value
    }

    assertEqual(testCases: [
      Pair(square(1), 1),
      xPair(square(2), 4),
      Pair(square(7), 49),
    ])

    XCTAssertEqual(calledInputs, [1, 7])
  }

  func testLazyEvaluationForInclusion() {
    var calledInputs: [Int] = []

    func square(_ value: Int) -> Int {
      calledInputs.append(value)
      return value * value
    }

    assertEqual(testCases: [
      fPair(square(1), 1),
      fPair(square(2), 4),
      Pair(square(7), 49),
    ])

    XCTAssertEqual(calledInputs, [1, 2])
  }

  func testMessageLaziness_Pair() {
    var callCount = 0
    func makeMessage() -> String {
      callCount += 1
      return "the message"
    }
    let pair = Pair(1, 2, makeMessage())
    XCTAssertEqual(callCount, 0)
    XCTAssertEqual(pair.message, "the message")
    XCTAssertEqual(callCount, 1)
  }

  func testMessageLaziness_fPair() {
    var callCount = 0
    func makeMessage() -> String {
      callCount += 1
      return "the message"
    }
    let pair = fPair(1, 2, makeMessage())
    XCTAssertEqual(callCount, 0)
    XCTAssertEqual(pair.message, "the message")
    XCTAssertEqual(callCount, 1)
  }

  func testMessageLaziness_xPair() {
    var callCount = 0
    func makeMessage() -> String {
      callCount += 1
      return "the message"
    }
    let pair = xPair(1, 2, makeMessage())
    XCTAssertEqual(callCount, 0)
    XCTAssertEqual(pair.message, "the message")
    XCTAssertEqual(callCount, 1)
  }
}
