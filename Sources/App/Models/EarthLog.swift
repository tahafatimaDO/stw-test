//
//  EarthLog.swift
//  
//
//  Created by Maarten Engels on 01/01/2022.
//

import Vapor
import Fluent
import Simulation

/// The `EarthLog` class stores log messages for a specific earth using the Bucket pattern.
/// https://www.mongodb.com/developer/how-to/bucket-pattern/
final class EarthLog: Content, Model {
    static let schema = "earth_logs"
    static let MAX_ENTRIES_PER_DOCUMENT = 128
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "earthID")
    var earthID: UUID
    
    @Field(key: "entries")
    var entries: [String]
    
    /// Start data and end-date use to help sorting and (perhaps later) filtering.
    @Field(key: "start_date")
    var startDate: Date
    
    /// Start data and end-date use to help sorting and (perhaps later) filtering.
    @Field(key: "end_date")
    var endDate: Date
        
    @Field(key: "entry_count")
    var entrtyCount: Int
    
    init() {}
    
    init(earthID: UUID) {
        self.earthID = earthID
        self.entries = []
        self.startDate = Date()
        self.endDate = Date()
        self.entrtyCount = 0
    }
    
    /// Log a message for an earth.
    /// - Parameters:
    ///   - message: the message to log.
    ///   - earthID: the earth the message applies to.
    ///   - db: the database connection to use to store the log.
    static func logMessage(_ message: String, for earthID: UUID, on db: Database) async throws {
        let existingLogCount = try await EarthLog.query(on: db).filter(\.$earthID, .equal, earthID).count()

        var earthLog: EarthLog
        if existingLogCount > 0 {
            earthLog = try await EarthLog.query(on: db).filter(\.$earthID, .equal, earthID).sort(\.$startDate).range(existingLogCount - 1 ..< existingLogCount).first()!
        } else {
            earthLog = EarthLog(earthID: earthID)
        }
        
        if earthLog.entrtyCount < MAX_ENTRIES_PER_DOCUMENT {
            // There is still room to append
            earthLog.entries.append(message)
            earthLog.entrtyCount += 1
            earthLog.endDate = Date()
        } else {
            // We need to create a new document.
            earthLog = EarthLog(earthID: earthID)
            earthLog.entries.append(message)
            earthLog.entrtyCount += 1
            earthLog.endDate = Date()
        }
        
        try await earthLog.save(on: db)
        
    }
    
    /// Returns the last log messages for a specific earth.`
    /// - Parameters:
    ///   - earthID: The earth for which we want to retrieve log messages;
    ///   - db: The database connection to use for the queries
    ///   - maxEntries: The maximum amount of entries to retrieve. Default: 20
    /// - Returns: An array of strings with the latest log messages for the earth.
    static func getLastLogMessages(earthID: UUID, on db: Database, maxEntries: Int = 20) async throws -> [String] {
        
        // See how many LogEntry documents there are in the database in total.
        let earthLogCount = try await EarthLog.query(on: db)
            .filter(\.$earthID, .equal, earthID)
            .count()
        
        // If there are none, we will return an empty array and log a message.
        guard earthLogCount > 0 else {
            db.logger.info("No log entries found for EarthModel \(earthID.uuidString)")
            return []
        }
        
        // The least amount of entries that can be found are MAX_ENTRIES_PER_DOCUMENT + 1. We'll create a warning if more are requested.
        if maxEntries > MAX_ENTRIES_PER_DOCUMENT {
            db.logger.warning("Requested more entries than maximum stored per log entry. Less than requested number of entries might be returned.")
        }
        
        // We try to retrieve the last two EarthLog entries, so we should always have enought to provide the maximum requested entries.
        let offset = max(0, earthLogCount - 2)
        let latestEarthLogEntries = try await EarthLog.query(on: db)
            .filter(\.$earthID, .equal, earthID)
            .sort(\.$startDate)
            .range(offset ..< earthLogCount)
            .all()
        
        /// convert the `entries` arrays from both `EarthLog`s into one bigger array.
        let logEntries = latestEarthLogEntries.flatMap { $0.entries }
        
        let count = min(logEntries.count, maxEntries)
        let lastEntries = Array(logEntries.reversed()[0 ..< count])
        return lastEntries
        
    }
}
