//
//  EarthLogController.swift
//
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor

struct EarthLogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let earthModels = routes.grouped("logs")
        
        earthModels.group(":earthModelID") { earthModel in
            earthModel.get(use: getEarthLogs)
        }
    }
    
    /// Returns the last 20 EarthLog messages for a specific Earth.
    /// - Parameter req: the request that holds the `:earthModelID` parameter.
    /// - Returns: The last 20 EarthLog messages
    func getEarthLogs(req: Request) async throws -> [String] {
        guard let earthModelIDString = req.parameters.get("earthModelID") else {
            throw Abort(.badRequest)
        }
        
        guard let earthModelID = UUID(uuidString: earthModelIDString) else {
            throw Abort(.notFound)
        }
        
        return try await EarthLog.getLastLogMessages(earthID: earthModelID, on: req.db, maxEntries: 20)
    }
}

