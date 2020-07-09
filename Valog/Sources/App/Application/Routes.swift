//import Fluent
import Vapor

func routes(_ app: Application) throws {
    
//    let view = try c.make(ViewRenderer.self)

//    app.get { _ in // req -> EventLoopFuture<View> in
//        welcome()
//    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }
    
    let api = app.grouped("api").grouped(AccessLogMiddleware())
    try api.register(collection: UserController())
    try api.register(collection: PostController())
    try api.register(collection: PostCommentsController())
    try api.register(collection: WebhooksController())
    
    let admin = api.grouped("admin")
    try admin.register(collection: AdminController())
    
    api.get("test") { _ in
        return "Foo: Bar"
    }

//    let todoController = TodoController()
//    app.get("todos", use: todoController.index)
//    app.post("todos", use: todoController.create)
//    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
}
