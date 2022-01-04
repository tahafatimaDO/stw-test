//
//  EarthModelController.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor

struct EarthModelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let earthModels = routes.grouped("earthModels")
        earthModels.get(use: index)
        
        earthModels.group(":earthModelID") { earthModel in
            earthModel.get(use: getEarthModel)
        }
    }
    
    func getEarthModel(req: Request) throws -> EventLoopFuture<EarthModel> {
        EarthModel.find(req.parameters.get("earthModelID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    // FIXME: For debugging purposes only
    func index(req: Request) throws -> EventLoopFuture<[EarthModel]> {
        return EarthModel.query(on: req.db).all()
    }
}
