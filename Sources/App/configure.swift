import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // configure JWT
    guard let jwks = FileManager.default.contents(atPath: app.directory.workingDirectory + (Environment.get("JWKS_KEYPAIR_FILE") ?? "keypair.jwks")),
          let jwksString = String(data: jwks, encoding: .utf8)
    else { fatalError("Failed to load JWKS Keypair file.") }
    try app.jwt.signers.use(jwksJSON: jwksString)
    
    // postgres configuration
    let dbport = Environment.get("POSTGRES_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname:   Environment.get("DATABASE_HOST") ?? "localhost",
        port:       app.environment == .testing ? 5433 : dbport,
        username:   Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password:   Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database:   Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    
    // run migraitons
    try migrations(app)
    // register routes
    try routes(app)
    
    // dev testing
    switch app.environment {
    case .testing:
        app.logger.info("Environment: testing")
        app.passwords.use(.plaintext)
        try await app.autoMigrate()
    case .development:
        app.logger.info("Environment: development")
        try await app.autoMigrate()
    default:
        break
    }
}
