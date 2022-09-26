import XCTest
@testable import LogBook

final class LogBookTests: XCTestCase {
    func testLogging() async throws {
        // given
        let book = LogBook(persistance: InMemoryPersistance())
        let logger = book.makeLogger("Test", in: "LogBookTests")

        let oldLogs = await book.logs()
        XCTAssert(oldLogs.isEmpty)

        // when
        logger.info("Testing LogBook.Logger.info...")
        logger.error("Some failure happened")

        // then
        let logs = await book.logs()
        let displayer = TextLogDisplayer()
        let textLogs = logs.map(displayer.display(log:))
        
        XCTAssertEqual(textLogs, [
            "[LogBookTests.Test][INFO] Testing LogBook.Logger.info...",
            "[LogBookTests.Test][ERROR] Some failure happened"
        ])
    }
}
