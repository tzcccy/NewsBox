//
//  UserController.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Foundation
import Vapor

///
final class UserController{

    func register(req : Request)throws -> Future<ResponseModel<UserRegistInfo> >{
        let user = try req.content.decode(UserRegistInfo.self)
        return user.save(on: req).map(to: ResponseModel.self){userinfo in
            let response = ResponseModel<UserRegistInfo>(status: 0, message: "成功", data: nil)
            return response
        }
    }
    
    func getVerifyCode(req : Request)throws ->Future<HTTPResponseStatus>{
        let email = try req.content.decode(PUBGBoxEmail.self)
        return email.flatMap { (mail) -> (Future<HTTPResponseStatus>) in
            return try PUBGBoxEmail.sendEmailCode(mail.email, req).map({ (flag) -> HTTPResponseStatus in
                if flag {
                    return HTTPResponseStatus.ok
                }
                return HTTPResponseStatus.badRequest
            })
        }
    }
    
}
