import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It's alive!"
    }
//
//    app.get("hello") { req -> String in
//        return "Hello, world!"
//    }

struct Alive:Content {
let message: String
}
    app.get("alive") { req -> Alive in
	return Alive(message: "OK") 
    }

    try app.register(collection: EarthModelController())
    try app.register(collection: CountryModelController())
    try app.register(collection: GameController())
    try app.register(collection: AuthenticationController())
    try app.register(collection: EarthLogController())
}
