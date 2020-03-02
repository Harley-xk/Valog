import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrapColoredLogger(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
