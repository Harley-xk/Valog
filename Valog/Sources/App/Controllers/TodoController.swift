//import Fluent
//import Vapor
//
//struct TodoController {
//    func index(req: Request) throws -> EventLoopFuture<Page<User>> {
//        return User.query(on: req.db).paginate(for: req)
//    }
//
//    func create(req: Request) throws -> EventLoopFuture<Todo> {
//        let todo = try req.content.decode(Todo.self)
//        return todo.save(on: req.db).map { todo }
//    }
//
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return Todo.find(req.parameters.get("todoID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .map { .ok }
//    }
//}
