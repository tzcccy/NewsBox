//
//  UserLoginInfo.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Vapor
import FluentMySQL
import Crypto

enum UserRegistEnum : String {
    case ok = "注册成功"
    case verifycodeError    =    "验证码错误"
    case useralreadyexist   =    "用户名已被注册"
    case passwordisEmpty    =    "密码不能为空"
    case emailisEmpty       =    "邮箱不能为空"
    case verifycodeisEmpty  =    "验证码不能为空"
}




final class UserRegistInfo : MySQLModel{
    static var entity = "user_regist_info"
    var id : Int?
    var username    :   String
    var password    :   String?
    var email       :   String?
    var verifycode  :   String?
    init(_ id : Int?, _ username : String, password : String?, _ email : String?,_ verifycode : String?) {
        self.id = id
        self.username = username
        self.password = password
        self.email    = email
        self.verifycode = verifycode
    }
}

extension UserRegistInfo{
    func check(req : Request)throws -> Future<UserRegistEnum>{
        /// 第一步，检查数据完整性
        guard self.password != nil else {
            return req.eventLoop.newSucceededFuture(result: .passwordisEmpty)
        }
        guard let email = self.email else{
            return req.eventLoop.newSucceededFuture(result: .emailisEmpty)
        }
        guard let verifyCode = self.verifycode else {
            return req.eventLoop.newSucceededFuture(result: .verifycodeisEmpty)
        }
        
        // 检查验证码是否正确
        let userMail = PUBGBoxEmail(email: email, verifycode: verifyCode)
        if !userMail.checkVerifyCode() {
            return req.eventLoop.newSucceededFuture(result: .verifycodeError)
        }
        // 第二步，检查是否注册过
        return try UserRegistInfo.query(on: req).filter(\UserRegistInfo.username == self.username).first().map(){ user in
            if user != nil {
                return .useralreadyexist
            }
            return .ok
        }
    }

}

extension UserRegistInfo : Migration { }
/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension UserRegistInfo: Content { }

