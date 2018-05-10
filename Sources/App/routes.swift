import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    
    //用户数据
    let userController = UserController()
    
    router.post("register", use: userController.register)
    router.post("getverifycode", use: userController.getVerifyCode)
}
