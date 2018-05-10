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

    /// 用户注册
    func register(req : Request)throws -> Future<ResponseModel<UserRegistInfo> >{
        return try req.content.decode(UserRegistInfo.self).flatMap(){ user in
            return try user.check(req: req).flatMap(){checkresult in
                if checkresult == .ok {
                    try user.encryptPassword()
                    return user.save(on: req).map(){ user in
                        return ResponseModel<UserRegistInfo>(status: 0, message: "注册成功", data: user)
                        }
                }else{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status: -1, message: checkresult.rawValue, data: nil))
                    
                }
            }
        }
        
    }
    
    
    /// 获取验证码
    func getVerifyCode(req : Request)throws ->Future<ResponseModel<String> >{
        let email = try req.content.decode(PUBGBoxEmail.self)
        return email.map { (mail) -> (ResponseModel<String>) in
            
            let sendEmailResult = PUBGBoxEmail.sendEmailCode(mail.email)
            if sendEmailResult {
                return ResponseModel<String>(status: 0, message: "发送验证码成功", data: nil)
            }
            return ResponseModel<String>(status: -1, message: "发送验证码失败", data: nil)
        }
    }
    
}
