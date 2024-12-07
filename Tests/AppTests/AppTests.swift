@testable import App
import XCTVapor
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()   
            try await test(app)
            try await app.autoRevert()   
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    // Login without a user in the database
    @Test("Failed Login Route")
    func failedLogin() async throws {
        try await withApp { app in
            let loginDTO = Auth_DTO.Login.Body(email: "noone@example.com", password: "12345")
            
            try await app.test(
                .POST, "api/auth/login",
                beforeRequest: { req in
                    try req.content.encode(loginDTO)
                },
                afterResponse: { res async in
                    #expect(res.status == .badRequest)
                })
        }
    }
    
    // Create a user, try to login with credentials
    @Test("Successful Login Route")
    func successfulLogin() async throws {
        try await withApp { app in
            let loginDTO = Auth_DTO.Login.Body(email: "test@test.com", password: "test123")
            let user = User(username: "test", fullName: "Test McGee",
                            email: "test@test.com", passwordHash: "test123",
                            isAdmin: true, isActive: true, isReset: false)
            
            try await user.create(on: app.db)
            try await app.test(
                .POST, "api/auth/login",
                beforeRequest: { req in
                    try req.content.encode(loginDTO)
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                })
        }
    }
    
//    @Test("Test Hello World Route")
//    func helloWorld() async throws {
//        try await withApp { app in
//            try await app.test(.GET, "hello", afterResponse: { res async in
//                #expect(res.status == .ok)
//                #expect(res.body.string == "Hello, world!")
//            })
//        }
//    }
//    
//    @Test("Getting all the Todos")
//    func getAllTodos() async throws {
//        try await withApp { app in
//            let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
//            try await sampleTodos.create(on: app.db)
//            
//            try await app.test(.GET, "todos", afterResponse: { res async throws in
//                #expect(res.status == .ok)
//                #expect(try res.content.decode([TodoDTO].self) == sampleTodos.map { $0.toDTO()} )
//            })
//        }
//    }
//    
//    @Test("Creating a Todo")
//    func createTodo() async throws {
//        let newDTO = TodoDTO(id: nil, title: "test")
//        
//        try await withApp { app in
//            try await app.test(.POST, "todos", beforeRequest: { req in
//                try req.content.encode(newDTO)
//            }, afterResponse: { res async throws in
//                #expect(res.status == .ok)
//                let models = try await Todo.query(on: app.db).all()
//                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
//                XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
//            })
//        }
//    }
//    
//    @Test("Deleting a Todo")
//    func deleteTodo() async throws {
//        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
//        
//        try await withApp { app in
//            try await testTodos.create(on: app.db)
//            
//            try await app.test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
//                #expect(res.status == .noContent)
//                let model = try await Todo.find(testTodos[0].id, on: app.db)
//                #expect(model == nil)
//            })
//        }
//    }
}
//
//extension TodoDTO: Equatable {
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.id == rhs.id && lhs.title == rhs.title
//    }
//}
