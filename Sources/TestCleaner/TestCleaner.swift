import XCTest

// MARK: - Types

public protocol Throwability {}

public extension XCTestCase {

  /// Whether a test pair is excluded or focused in a test run.
  enum Involvement {
    /// This test pair is excluded, and will not be evaluated when the test is run
    case excluded

    /// This test pair is focused, meaning that only it and other focused pairs will be evaluated. All non-focused pairs will be excluded.
    case focused
  }

  enum Throws: Throwability {}
  enum DoesNotThrow: Throwability {}

  /// A pair of values representing observed and expected values in a test.
  struct TestPair<Left, Right, CanThrow: Throwability> {

    /// The left-hand value in the pair. Might represent the observed value in a test, or the left-hand side of a comparison expression.
    private let leftClosure: () throws -> Left

    /// The right-hand value in the pair. Might represent the expected value in a test, or the right-hand side of a comparison expression.
    private let rightClosure: () throws -> Right

    /// An optional description of the failure.
    let messageClosure: () -> String

    /// The file in which the `TestPair` was initialized.
    let file: StaticString

    /// The line on which the `TestPair` was initialized.
    let line: UInt

    /// The involvement of this `TestPair`.
    public let involvement: Involvement?

    /// An optional description of the failure.
    public var message: String {
      messageClosure()
    }
  }
}

extension XCTestCase.TestPair where CanThrow == XCTestCase.DoesNotThrow {

  /// Initializes a new `TestPair`, capturing the file and line information for use in `XCTest` methods.
  /// - Parameters:
  ///   - left: a closure that generates the left-hand value.
  ///   - right: the closure that generates the right-hand value.
  ///   - involvement: the involvement of this test pair.
  ///   - message: an optional description of the failure.
  ///   - file: the file in which the `TestPair` was initialized.
  ///   - line: the line in which the `TestPair` was initialized.
  public init(
    _ left: @escaping () -> Left,
    _ right: @escaping () -> Right,
    involvement: XCTestCase.Involvement?,
    message: @escaping () -> String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    self.leftClosure = left
    self.rightClosure = right
    self.involvement = involvement
    self.messageClosure = message
    self.file = file
    self.line = line
  }

  /// The left-hand value in the pair. Might represent the observed value in a test, or the left-hand side of a comparison expression.
  public var left: Left {
    get {
      try! leftClosure()
    }
  }

  /// The right-hand value in the pair. Might represent the expected value in a test, or the right-hand side of a comparison expression.
  public var right: Right {
    get {
      try! rightClosure()
    }
  }
}

extension XCTestCase.TestPair where CanThrow == XCTestCase.Throws {

  /// Initializes a new `TestPair`, capturing the file and line information for use in `XCTest` methods.
  /// - Parameters:
  ///   - left: a closure that generates the left-hand value.
  ///   - right: the closure that generates the right-hand value.
  ///   - involvement: the involvement of this test pair.
  ///   - message: an optional description of the failure.
  ///   - file: the file in which the `TestPair` was initialized.
  ///   - line: the line in which the `TestPair` was initialized.
  public init(
    _ left: @escaping () throws -> Left,
    _ right: @escaping () throws -> Right,
    involvement: XCTestCase.Involvement?,
    message: @escaping () -> String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    self.leftClosure = left
    self.rightClosure = right
    self.involvement = involvement
    self.messageClosure = message
    self.file = file
    self.line = line
  }

  /// The left-hand value in the pair. Might represent the observed value in a test, or the left-hand side of a comparison expression.
  public var left: Left {
    get throws {
      try leftClosure()
    }
  }

  /// The right-hand value in the pair. Might represent the expected value in a test, or the right-hand side of a comparison expression.
  public var right: Right {
    get throws {
      try rightClosure()
    }
  }
}

// MARK: - Test Pair Convenience Functions

public extension XCTestCase {

  /// Creates a test pair that is evaluated in the enclosing test, unless it appears alongside a focused pair as denoted by `fPair`.
  func Pair<Left, Right>(
    _ left: @autoclosure @escaping () -> Left,
    _ right: @autoclosure @escaping () -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, DoesNotThrow> {
    TestPair(left, right, involvement: nil, message: message, file: file, line: line)
  }

  /// Creates a test pair that is evaluated in the enclosing test, unless it appears alongside a focused pair as denoted by `fPair`.
  @_disfavoredOverload func Pair<Left, Right>(
    _ left: @autoclosure @escaping () throws -> Left,
    _ right: @autoclosure @escaping () throws -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, Throws> {
    TestPair(left, right, involvement: nil, message: message, file: file, line: line)
  }

  /// Creates a test pair that is skipped when running the enclosing test.
  func xPair<Left, Right>(
    _ left: @autoclosure @escaping () -> Left,
    _ right: @autoclosure @escaping () -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, DoesNotThrow> {
    TestPair(left, right, involvement: .excluded, message: message, file: file, line: line)
  }

  /// Creates a test pair that is skipped when running the enclosing test.
  @_disfavoredOverload func xPair<Left, Right>(
    _ left: @autoclosure @escaping () throws -> Left,
    _ right: @autoclosure @escaping () throws -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, Throws> {
    TestPair(left, right, involvement: .excluded, message: message, file: file, line: line)
  }

  /// Creates a test pair that is always run when the enclosing test is run. Causes any non-focused pairs to be skipped. If a test contains multiple focused pairs, they will all be run.
  func fPair<Left, Right>(
    _ left: @autoclosure @escaping () -> Left,
    _ right: @autoclosure @escaping () -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, DoesNotThrow> {
    TestPair(left, right, involvement: .focused, message: message, file: file, line: line)
  }

  /// Creates a test pair that is always run when the enclosing test is run. Causes any non-focused pairs to be skipped. If a test contains multiple focused pairs, they will all be run.
  @_disfavoredOverload func fPair<Left, Right>(
    _ left: @autoclosure @escaping () throws -> Left,
    _ right: @autoclosure @escaping () throws -> Right,
    _ message: @autoclosure @escaping () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right, Throws> {
    TestPair(left, right, involvement: .focused, message: message, file: file, line: line)
  }

}

public extension XCTestCase {

  /// Assert that a given set of input booleans (e.g. the result of some transformation) matches a given set of output booleans
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  func assertBoolean(testCases: [TestPair<Bool, Bool, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      if testCase.right {
        XCTAssertTrue(
          testCase.left,
          testCase.message,
          file: testCase.file,
          line: testCase.line
        )
      } else {
        XCTAssertFalse(
          testCase.left,
          testCase.message,
          file: testCase.file,
          line: testCase.line
        )
      }
    }
  }

  /// Assert that a given set of input booleans (e.g. the result of some transformation) matches a given set of output booleans
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  @_disfavoredOverload func assertBoolean(testCases: [TestPair<Bool, Bool, Throws>]) {
    do {
      for testCase in testCases.pairsToTest {
        if try testCase.right {
          XCTAssertTrue(
            try testCase.left,
            testCase.message,
            file: testCase.file,
            line: testCase.line
          )
        } else {
          XCTAssertFalse(
            try testCase.left,
            testCase.message,
            file: testCase.file,
            line: testCase.line
          )
        }
      }
    } catch {
      XCTFail("Caught error while running assertBoolean: \(error)")
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than on the right.
  @_disfavoredOverload func assertLessThan<T: Comparable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThan(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than on the right.
  @_disfavoredOverload func assertLessThan<T: Comparable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThan(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than on the right.
  func assertGreaterThan<T: Comparable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThan(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than on the right.
  @_disfavoredOverload func assertGreaterThan<T: Comparable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThan(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than or equal to on the right.
  func assertLessThanOrEqual<T: Comparable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThanOrEqual(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than or equal to on the right.
  @_disfavoredOverload func assertLessThanOrEqual<T: Comparable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThanOrEqual(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than or equal to on the right.
  func assertGreaterThanOrEqual<T: Comparable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThanOrEqual(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than or equal to on the right.
  @_disfavoredOverload func assertGreaterThanOrEqual<T: Comparable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThanOrEqual(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  func assertEqual<T: Equatable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  @_disfavoredOverload func assertEqual<T: Equatable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered equal.
  func assertEqual<T: FloatingPoint>(testCases: [TestPair<T, T, DoesNotThrow>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(
        testCase.left,
        testCase.right,
        accuracy: accuracy,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered equal.
  @_disfavoredOverload func assertEqual<T: FloatingPoint>(testCases: [TestPair<T, T, Throws>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(
        try testCase.left,
        try testCase.right,
        accuracy: accuracy,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  func assertNotEqual<T: Equatable>(testCases: [TestPair<T, T, DoesNotThrow>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(
        testCase.left,
        testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  @_disfavoredOverload func assertNotEqual<T: Equatable>(testCases: [TestPair<T, T, Throws>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(
        try testCase.left,
        try testCase.right,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered not equal.
  func assertNotEqual<T: FloatingPoint>(testCases: [TestPair<T, T, DoesNotThrow>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(
        testCase.left,
        testCase.right,
        accuracy: accuracy,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered not equal.
  @_disfavoredOverload func assertNotEqual<T: FloatingPoint>(testCases: [TestPair<T, T, Throws>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(
        try testCase.left,
        try testCase.right,
        accuracy: accuracy,
        testCase.message,
        file: testCase.file,
        line: testCase.line
      )
    }
  }

  /**
   Run a custom `test` closure on a given set of test pairs.
   - Parameter testCases: the cases to test. The meaning of the left and right values will depend on the body of the `tests` closure.
   - Parameter tests: a closure containing one or more test assertions. For the line highlighting on test failure to work properly, pass the `file` and `line` parameters from this closure to your custom testing code.

   Example:

   ```
   assertCustom(
     testCases: [
       Pair(someLeftValue, someRightValue),
       Pair(anotherLeftValue, anotherRightValue),
     ],
     tests: { pair, file, line in
       myCustomAssertion(
         pair.left, pair.right,
         message: pair.message,
         file: file, line: line // <-- ⚠️ file and line are important!
       )
       try youCanAlsoThrowErrorsInHere() // They will also get attributed to the correct line.
     }
   )
   ```
   */
  func assertCustom<T, U>(
    testCases: [TestPair<T, U, DoesNotThrow>],
    tests: (TestPair<T, U, DoesNotThrow>, _ file: StaticString, _ line: UInt) -> Void
  ) {
    for testCase in testCases.pairsToTest {
      tests(testCase, testCase.file, testCase.line)
    }
  }

  /**
   Run a custom `test` closure on a given set of test pairs.
   - Parameter testCases: the cases to test. The meaning of the left and right values will depend on the body of the `tests` closure.
   - Parameter tests: a closure containing one or more test assertions. For the line highlighting on test failure to work properly, pass the `file` and `line` parameters from this closure to your custom testing code.

   Example:

   ```
   assertCustom(
     testCases: [
       Pair(someLeftValue, someRightValue),
       Pair(anotherLeftValue, anotherRightValue),
     ],
     tests: { pair, file, line in
       myCustomAssertion(
         pair.left, pair.right,
         message: pair.message,
         file: file, line: line // <-- ⚠️ file and line are important!
       )
       try youCanAlsoThrowErrorsInHere() // They will also get attributed to the correct line.
     }
   )
   ```
   */
  @_disfavoredOverload func assertCustom<T, U>(
    testCases: [TestPair<T, U, Throws>],
    tests: (TestPair<T, U, Throws>, _ file: StaticString, _ line: UInt) throws -> Void
  ) {
    for testCase in testCases.pairsToTest {
      do {
        try tests(testCase, testCase.file, testCase.line)
      } catch {
        XCTFail("Failed: '\(error)' for test case '\(testCase.message)'", file: testCase.file, line: testCase.line)
      }
    }
  }

}

/// Describes a type that can express its preference for being focused or skipped during testing.
public protocol HasTestInvolvement {
  /// The type's preference for being focused or skipped during testing.
  var involvement: XCTestCase.Involvement? { get }
}

extension XCTestCase.TestPair: HasTestInvolvement {}

public extension Sequence where Element: HasTestInvolvement {

  /// The filtered list of test pairs to use during testing. Takes test involvement into account, skipping any `xPair` tests, or skipping all non-focused pairs if any `fPair` tests are present.
  var pairsToTest: [Element] {
    if self.contains(where: { $0.involvement == .focused }) {
      return filter { $0.involvement == .focused }
    }
    return filter { $0.involvement != .excluded }
  }

}
