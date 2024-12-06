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
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // register routes
    try routes(app)
}
