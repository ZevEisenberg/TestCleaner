import XCTest

// MARK: - Types

public extension XCTestCase {

  /// Whether a test pair is excluded or focused in a test run.
  enum Affinity {
    /// This test pair is excluded, and will not be evaluated when the test is run
    case excluded

    /// This test pair is focused, meaning that only it and other focused pairs will be evaluated. All non-focused pairs will be excluded.
    case focused
  }

  /// A pair of values representing observed and expected values in a test.
  struct TestPair<Left, Right> {

    /// The left-hand value in the pair. Might represent the observed value in a test, or the left-hand side of a comparison expression.
    public let left: Left

    /// The right-hand value in the pair. Might represent the expected value in a test, or the right-hand side of a comparison expression.
    public let right: Right

    /// The file in which the `TestPair` was initialized.
    let file: StaticString

    /// The line on which the `TestPair` was initialized.
    let line: UInt

    /// The affinity of this `TestPair`.
    public let affinity: Affinity?

    /// Initializes a new `TestPair`, capturing the file and line information for use in `XCTest` methods.
    /// - Parameters:
    ///   - left: the left-hand value.
    ///   - right: the right-hand value.
    ///   - affinity: the affinity of this test pair.
    ///   - file: the file in which the `TestPair` was initialized.
    ///   - line: the line in which the `TestPair` was initialized.
    init(_ left: Left, _ right: Right, affinity: Affinity?, file: StaticString = #filePath, line: UInt = #line) {
      self.left = left
      self.right = right
      self.affinity = affinity
      self.file = file
      self.line = line
    }
  }

}

// MARK: - Test Pair Convenience Functions

public extension XCTestCase {

  /// Creates a test pair that is evaluated in the enclosing test, unless it appears alongside a focused pair as denoted by `fPair`.
  func Pair<Left, Right>(
    _ left: Left,
    _ right: Right,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right> {
    TestPair(left, right, affinity: nil, file: file, line: line)
  }

  /// Creates a test pair that is skipped when running the enclosing test.
  func xPair<Left, Right>(
    _ left: Left,
    _ right: Right,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right> {
    TestPair(left, right, affinity: .excluded, file: file, line: line)
  }

  /// Creates a test pair that is always run when the enclosing test is run. Causes any non-focused pairs to be skipped. If a test contains multiple focused pairs, they will all be run.
  func fPair<Left, Right>(
    _ left: Left,
    _ right: Right,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> TestPair<Left, Right> {
    TestPair(left, right, affinity: .focused, file: file, line: line)
  }

}

public extension XCTestCase {

  /// Assert that a given set of input booleans (e.g. the result of some transformation) matches a given set of output booleans
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  func assertBoolean(testCases: [TestPair<Bool, Bool>]) {
    for testCase in testCases.pairsToTest {
      if testCase.right {
        XCTAssertTrue(testCase.left, file: testCase.file, line: testCase.line)
      } else {
        XCTAssertFalse(testCase.left, file: testCase.file, line: testCase.line)
      }
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than on the right.
  func assertLessThan<T: Comparable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThan(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than on the right.
  func assertGreaterThan<T: Comparable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThan(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate to less than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be less than or equal to on the right.
  func assertLessThanOrEqual<T: Comparable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertLessThanOrEqual(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate to greater than or equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the value it is expected to be greater than or equal to on the right.
  func assertGreaterThanOrEqual<T: Comparable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertGreaterThanOrEqual(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  func assertEqual<T: Equatable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate as equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered equal.
  func assertEqual<T: FloatingPoint>(testCases: [TestPair<T, T>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertEqual(testCase.left, testCase.right, accuracy: accuracy, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  func assertNotEqual<T: Equatable>(testCases: [TestPair<T, T>]) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(testCase.left, testCase.right, file: testCase.file, line: testCase.line)
    }
  }

  /// Assert that a given set of input values uniformly evaluate as not equal (within a specified accuracy) to a given set of control values.
  /// - Parameter testCases: the cases to test, with the test value on the left and the expected unequal value on the right.
  /// - Parameter accuracy: An expression of type `T`, where T conforms to `FloatingPoint`. This parameter describes the maximum difference between the test and control values for these values to be considered not equal.
  func assertNotEqual<T: FloatingPoint>(testCases: [TestPair<T, T>], accuracy: T) {
    for testCase in testCases.pairsToTest {
      XCTAssertNotEqual(testCase.left, testCase.right, accuracy: accuracy, file: testCase.file, line: testCase.line)
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
         file: file, line: line // <-- ⚠️ this is important!
       )
     }
   )
   ```
   */
  func assertCustom<T, U>(
    testCases: [TestPair<T, U>],
    tests: (TestPair<T, U>, _ file: StaticString, _ line: UInt) throws -> Void
  ) rethrows {
    for testCase in testCases.pairsToTest {
      try tests(testCase, testCase.file, testCase.line)
    }
  }

}

/// Describes a type that can express its preference for being focused or skipped during testing.
public protocol HasTestAffinity {
  /// The type's preference for being focused or skipped during testing.
  var affinity: XCTestCase.Affinity? { get }
}

extension XCTestCase.TestPair: HasTestAffinity {}

public extension Sequence where Element: HasTestAffinity {

  /// The filtered list of test pairs to use during testing. Takes test affinity into account, skipping any `xPair` tests, or skipping all non-focused pairs if any `fPair` tests are present.
  var pairsToTest: [Element] {
    if self.contains(where: { $0.affinity == .focused }) {
      return filter { $0.affinity == .focused }
    }
    return filter { $0.affinity != .excluded }
  }

}
