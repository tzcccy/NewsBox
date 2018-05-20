import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    
    
    
    //用户数据
    let userRouter = router.grouped("user")
    let userController = UserController()
    
    userRouter.post("register", use: userController.register)
    userRouter.post("getverifycode", use: userController.getVerifyCode)
    userRouter.post("login", use: userController.login)
    userRouter.post("logout", use: userController.logout)
    userRouter.post("update", use: userController.updateUserInfo)
    userRouter.post("uploadheadpic", use: userController.updateUserHeadPicture)
}
