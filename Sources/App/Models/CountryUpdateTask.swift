//
//  CountryUpdateTask.swift
//
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation
import Queues
import Vapor
import Simulation


/// Run this task to simulate a year has passed for all earths in the database.
///
/// The updated earths are saved to the database at the end of this task, so the database version has the most up-to-date version.
struct UpdateCountryTask: AsyncScheduledJob {
    // Add extra services here via dependency intection, if you need them.
    
    private let MIN_UPDATE_ELAPSED_TIME: TimeInterval = 600
    
    func run(context: QueueContext) async throws {
        // Do some work here, perhaps queue up another job.
        let updateDate = Date()
        context.logger.info("Running scheduled task 'UpdateCountryTask' at \(updateDate)")
        
        // get all the Earths
        let earths = try await EarthModel.query(on: context.application.db).all()
        
        for earthModel in earths {
            let countryModels = try await CountryModel.query(on: context.application.db)
                .filter(\.$earthID, .equal, earthModel.id!).all()
            
            for countryModel in countryModels {
                countryModel.country.tick(in: earthModel.earth)
                try await countryModel.save(on: context.application.db)
            }
        }
        
        context.logger.info("Finished updating countries.")
    }
}
