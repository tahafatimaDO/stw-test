//
//  AuthenticationController.swift
//  
//
//  Created by Maarten Engels on 30/12/2021.
//

import Vapor
import Fluent

struct AuthenticationController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let playerRoutes = routes.grouped("players")
        
        let passwordProtected = playerRoutes.grouped(Player.authenticator())
        passwordProtected.post("login") { req -> UserToken in
//            print(req)
            let player = try req.auth.require(Player.self)
            let token = try player.generateToken()
            try await token.save(on: req.db)
            return token
        }
        
//        let tokenProtected = playerRoutes.grouped(UserToken.authenticator())
//        tokenProtected.get("me") { req -> Player in
//            try req.auth.require(Player.self)
//        }
        
        //playerRoutes.get(use: index)
        playerRoutes.post(use: create)
    }
    
    private func claimCountry(player: Player, db: Database) async throws -> CountryModel {
        guard player.countryID == nil else {
            throw Player.PlayerError.playerAlreadyHasCountry
        }
        
        let availableCountryModels = try await CountryModel.query(on: db).filter(\.$playerID, .equal, .none).all()
        
        guard let availableCountryModel = availableCountryModels.randomElement() else {
            throw Player.PlayerError.noFreeCountriesAvailable
        }
        
        return availableCountryModel
    }
    
    func create(req: Request) async throws -> String {
        try Player.Create.validate(content: req)
        let create = try req.content.decode(Player.Create.self)
        
        
        guard create.password == create.confirmPassword else {
            return "Passwords did not match."
        }
        
        guard try await Player.query(on: req.db).filter(\.$email, .equal, create.email).first() == nil else {
            return "A player with this email address already exists. Please choose another one."
        }
        
        let player = try Player(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        
        try await player.save(on: req.db)
        
        // Let's get this player a country
        // First, let's get a country that hasn't been claimed yet.
        let countryModel = try await claimCountry(player: player, db: req.db)
        
        // Then, assign it to the player and vice versa.
        countryModel.playerID = player.id
        player.countryID = countryModel.id
        
        // Save changes
        try await countryModel.save(on: req.db)
        try await player.save(on: req.db)
        
        try await EarthLog.logMessage("\(countryModel.country.name) was claimed.", for: countryModel.earthID, on: req.db)
        
        return "Player succesfully created. You can now log in."
    }
    
//    // FIXME: for debug purposes only
//    func index(req: Request) throws -> EventLoopFuture<[Player]> {
//        return Player.query(on: req.db).all()
//    }
}

extension Player {
    enum PlayerError: Error {
        case userAlreadyExists
        case playerAlreadyHasCountry
        case noFreeCountriesAvailable
    }
    
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}

extension Player.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension Player: ModelAuthenticatable {
    static let usernameKey = \Player.$email
    static let passwordHashKey = \Player.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$player

    var isValid: Bool {
        Date() <= validThrough
    }
}

extension Player {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            playerID: self.requireID()
        )
    }
}
