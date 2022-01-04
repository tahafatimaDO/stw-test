//
//  EarthUpdateTask.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Foundation
import Queues
import Vapor
import Simulation


/// Run this task to simulate a year has passed for all earths in the database.
///
/// The updated earths are saved to the database at the end of this task, so the database version has the most up-to-date version.
struct UpdateEarthTask: AsyncScheduledJob {
    // Add extra services here via dependency intection, if you need them.
    
    private let MIN_UPDATE_ELAPSED_TIME: TimeInterval = 600
    
    func run(context: QueueContext) async throws {
        // Do some work here, perhaps queue up another job.
        let updateDate = Date()
        context.logger.info("Running scheduled task 'UpdateEarthTask' as \(updateDate)")
        
        // get all the Earths
        let earths = try await EarthModel.query(on: context.application.db).all()
        
        for earthModel in earths {
            // because scheduled tasks sometimes fire twice, we check whether some time has passed since the last "fire"
//            let elapsedTime = updateDate.timeIntervalSince(earthModel.lastUpdate)
//            context.logger.debug("Elapsed time since last update: \(elapsedTime)")
//
//            if elapsedTime > MIN_UPDATE_ELAPSED_TIME {
                let countryModels = try await CountryModel.query(on: context.application.db)
                    .filter(\.$earthID, .equal, earthModel.id!).all()
                
                let countries = countryModels.map { $0.country }
                
                let emissions = countries.map { $0.yearlyEmissions }
                let totalEmissions = emissions.reduce(0, +)
                
                context.logger.debug("Earth \(earthModel.id?.uuidString ?? "unknown") vitals before: \(earthModel.earth.debugVitals)")
                earthModel.earth.tick(yearlyEmission: totalEmissions)
                context.logger.debug("Earth \(earthModel.id?.uuidString ?? "unknown") vitals before: \(earthModel.earth.debugVitals)")
                
//                earthModel.lastUpdate = updateDate
                try await earthModel.save(on: context.application.db)
                
                try await EarthLog.logMessage("Welcome to \(earthModel.earth.currentYear)!", for: earthModel.id!, on: context.application.db)
//            }
        }
    }
}
