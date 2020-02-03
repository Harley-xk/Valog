//import Fluent
import Vapor

func routes(_ app: Application) throws {
    
//    let view = try c.make(ViewRenderer.self)

    app.get { // req -> EventLoopFuture<View> in
        $0.view.render("welcome")
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }

//    let todoController = TodoController()
//    app.get("todos", use: todoController.index)
//    app.post("todos", use: todoController.create)
//    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
}
