//
//  CleanupTask.swift
//  
//
//  Created by Maarten Engels on 02/01/2022.
//

import Queues
import Vapor
import Simulation


/// Run this task to perform various cleanup actions in the database.
///
/// Such as: deleting invalid tokens.
struct CleanupTask: AsyncScheduledJob {
    // Add extra services here via dependency intection, if you need them.
    
    func run(context: QueueContext) async throws {
        context.logger.info("Starting cleanup task at: \(Date())")
        
        context.logger.info("Starting token cleanup")
        let allTokens = try await UserToken.query(on: context.application.db).all()
        
        let invalidTokens = allTokens.filter { $0.isValid }
        for invalidToken in invalidTokens {
            try await invalidToken.delete(on: context.application.db)
        }
        
        context.logger.info("Token cleanup finished. Deleted \(invalidTokens.count) expired tokens.")
        
        context.logger.info("Finished cleanup.")
    }
}
