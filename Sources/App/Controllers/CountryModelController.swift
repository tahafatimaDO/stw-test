//
//  CountryModelController.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor

struct CountryModelController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let countryModels = routes.grouped("countryModels")
        countryModels.get(use: index)
        
        countryModels.group(":countryModelID") { countryModel in
            countryModel.get(use: getCountryModel)
        }
    }
    
    func getCountryModel(req: Request) throws -> EventLoopFuture<CountryModel> {
        CountryModel.find(req.parameters.get("countryModelID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    // FIXME: for debug purposes only
    func index(req: Request) throws -> EventLoopFuture<[CountryModel]> {
        return CountryModel.query(on: req.db).all()
    }
}
