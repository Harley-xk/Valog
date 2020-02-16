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
    
    try app.grouped("api")
        .register(collection: PostController())

//    let todoController = TodoController()
//    app.get("todos", use: todoController.index)
//    app.post("todos", use: todoController.create)
//    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
}
