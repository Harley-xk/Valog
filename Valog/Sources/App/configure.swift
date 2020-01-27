import Leaf
import Vapor

/// Called before your application initializes.
func configure(_ s: inout Services) throws {
    // Register providers first
    s.provider(LeafProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    // directory
    s.register(DirectoryConfiguration.self) { c in
        // Serves files from `Public/` directory
        #if Xcode
        // check if we are in Xcode via SPM integration
        let path = #file
        if !path.contains("SourcePackages/checkouts") {
            var fileBasedWorkDir: String? = nil
            // we are NOT in Xcode via SPM integration
            // use #file hacks to determine working directory automatically
            if #file.contains(".build") {
                // most dependencies are in `./.build/`
                fileBasedWorkDir = #file.components(separatedBy: "/.build").first
            } else if #file.contains("Packages") {
                // when editing a dependency, it is in `./Packages/`
                fileBasedWorkDir = #file.components(separatedBy: "/Packages").first
            } else {
                // when dealing with current repository, file is in `./Sources/`
                fileBasedWorkDir = #file.components(separatedBy: "/Sources").first
            }
            if let dir = fileBasedWorkDir {
                return .init(workingDirectory: dir)
            }
        }
        #endif
        return .detect()
    }
    
    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()

        // Serves files from `Public/` directory
        try middlewares.use(c.make(FileMiddleware.self))

        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))

        return middlewares
    }
}
