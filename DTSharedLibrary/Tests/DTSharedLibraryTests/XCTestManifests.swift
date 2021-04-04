import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(DTSharedLibraryTests.allTests)
    ]
}
#endif
