import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import QueuesMongoDriver
import Simulation


// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    
    try app.databases.use(.mongo(
        connectionString: Environment.get("STW_BACKEND_DB_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)
    
    
    let mongoDatabase = try MongoDatabase.lazyConnect(Environment.get("STW_BACKEND_DB_URL") ?? "mongodb://localhost:27017/vapor_database", on: app.eventLoopGroup.next())
    
    // Setup Indexes for the Job Schema for performance (Optional)
    try app.queues.setupMongo(using: mongoDatabase)
    app.queues.use(.mongodb(mongoDatabase))

    app.queues.schedule(UpdateEarthTask()).daily().at(12, 00)
    app.queues.schedule(CleanupTask()).daily().at(00, 01)
    app.queues.schedule(UpdateCountryTask()).hourly().at(00)
    
    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()
    
    initializeDatabase(db: app.db)
    
    let port = Int(Environment.get("STW_BACKEND_PORT") ?? "8000") ?? 8000
    app.http.server.configuration.port = port
    
    let host = Environment.get("STW_HOSTNAME") ?? "localhost"
    app.http.server.configuration.hostname = host
   
    // register routes
    try routes(app)
}

fileprivate func initializeDatabase(db: Database) {
    func loadCountries(baseEmission: Double) -> [Country] {
        struct CountryLoad: Codable {
            let countryName: String
            let twoCharacterCode: String
            let threeCharacterCode: String
            
            /// million metric tons of C
            let emission: Double
            
            /// GDP in current USD
            let gdp: Double
            
            /// headcount
            let population: Int
            let budget: Double
            let gini: Double
            let edi: Double
        }
     
        let url = URL(fileURLWithPath: "Data/CountryEmissionGDPPopulationBudgetGiniEdi.json")
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedCountries = try decoder.decode([CountryLoad].self, from: data)
            
            // Because our model uses only the weight of C in the atmosphere and our data source contains emissions of CO2 (i.e. includes the weight of O as well), we need to calculate the ratio of all emissions for each country.
            let totalEmissions = loadedCountries
                .map {$0.emission}                      // convert to array of emissions
                .reduce(0, +)                                   // sum all emissions
            
            
            
            return loadedCountries.map { loadedCountry in
                Country(name: loadedCountry.countryName,
                        countryCode: loadedCountry.twoCharacterCode,
                        baseYearlyEmissions: loadedCountry.emission / totalEmissions * baseEmission,
                        baseGDP: loadedCountry.gdp / 1000.0,
                        population: loadedCountry.population,
                        budgetSurplus: loadedCountry.budget,
                        giniRating: loadedCountry.gini,
                        educationDevelopmentIndex: loadedCountry.edi)
            }
        } catch {
            fatalError("Error during load: \(error)")
        }
    }
    
    
    do {
        if try EarthModel.query(on: db).all().wait().count == 0 {
            let countries = loadCountries(baseEmission: Earth.BASE_GLOBAL_EMISSIONS_2015)
            
            db.logger.info("Started creating earth model.")
            let earthModel = EarthModel()
            try earthModel.save(on: db).wait()
            db.logger.info("Finished saving earth model.")
            
            let countryModels = countries.map { country -> CountryModel in
                let countryModel = CountryModel(country: country, earthID: earthModel.id!)
                return countryModel
            }
            
            db.logger.info("Started saving countries.")
            try countryModels.forEach { try $0.save(on: db).wait() }
            db.logger.info("Finished saving countries.")
            
            db.logger.notice("Finished initiazing database.")
            
        } else {
            db.logger.notice("Found at least one earth model, skipping database initization.")
        }
    } catch {
        db.logger.error("Failed to initialize database: \(error)")
    }
    
}
