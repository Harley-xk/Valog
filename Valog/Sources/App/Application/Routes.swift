import Fluent
import Vapor

func routes(_ app: Application) throws {
    
//    let view = try c.make(ViewRenderer.self)

    app.get { req -> EventLoopFuture<View> in
        
        struct WelcomePageData: Content {
            var items: [String] = []
            var title = "欢迎"
        }
        
        return req.view.render("welcome", WelcomePageData())
    }
    
//    app.get { req in
//        return "It works!"
//    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
}
