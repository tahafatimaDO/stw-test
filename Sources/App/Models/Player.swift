//
//  Player.swift
//  
//
//  Created by Maarten Engels on 30/12/2021.
//

import Fluent
import Vapor

final class Player: Model, Content {
    static let schema = "players"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "country_id")
    var countryID: UUID?

    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.countryID = nil
    }
}

final class UserToken: Model, Content {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "player_id")
    var player: Player
    
    @Field(key: "valid_through")
    var validThrough: Date
    
    init() { }

    init(id: UUID? = nil, value: String, playerID: Player.IDValue) {
        self.id = id
        self.value = value
        self.$player.id = playerID
        self.validThrough = Date().addingTimeInterval(3600*24)
    }
}
