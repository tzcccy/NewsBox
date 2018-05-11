//
//  UserController.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Foundation
import Vapor
import FluentMySQL
///

fileprivate let paramError = "请求参数错误"
fileprivate let secretKeyError = "App鉴权错误"

final class UserController{

    /// 用户注册
    func register(req : Request)throws -> Future<ResponseModel<UserRegistInfo> >{
        return try req.content.decode(RequestModel<UserRegistInfo>.self).flatMap(){ requestBody in
            
            return try requestBody.JudgeSercretKey(req: req).flatMap(){result in
                if !result {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status: -3, message: secretKeyError, data: nil))
                }
                
                if requestBody.data == nil {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status: -2, message: paramError, data: nil))
                }
                
                return try requestBody.data!.check(req: req).flatMap(){checkresult in
                    if checkresult == .ok {
                        requestBody.data!.password = try encryptPassword(password: requestBody.data!.password!)
                        return requestBody.data!.save(on: req).map(){ user in
                            return ResponseModel<UserRegistInfo>(status: 0, message: "注册成功", data: user)
                        }
                    }else{
                        return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status: -1, message: checkresult.rawValue, data: nil))
                    }
                }
                
            }
        }
        
    }
    
    
    /// 获取验证码
    func getVerifyCode(req : Request)throws ->Future<ResponseModel<String> >{
        return try req.content.decode(RequestModel<PUBGBoxEmail>.self).flatMap { requestBody in
            
            return try requestBody.JudgeSercretKey(req: req).map(){result in
                if !result {
                    return ResponseModel<String>(status: -3, message: secretKeyError, data: nil)
                }
                
                guard let mail = requestBody.data else {
                    return ResponseModel<String>(status: -2, message: paramError, data: nil)
                }
                let sendEmailResult = PUBGBoxEmail.sendEmailCode(mail.email)
                if sendEmailResult {
                    return ResponseModel<String>(status: 0, message: "发送验证码成功", data: nil)
                }
                return ResponseModel<String>(status: -1, message: "发送验证码失败", data: nil)
            }
            
            
            
            
        }
    }
    
    /// 用户登陆
    func login(req : Request)throws -> Future<ResponseModel<AccessToken> >{
        return try req.content.decode(RequestModel<UserLoginInfo>.self).flatMap(){requestBody in
            
            
            return try requestBody.JudgeSercretKey(req: req).flatMap(){result in
                if !result {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<AccessToken>(status: -3, message: secretKeyError, data: nil))
                }
                
                guard let user = requestBody.data else {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<AccessToken>(status: -2, message: paramError, data: nil))
                }
                // 检查账户密码是否存在
                user.password = try encryptPassword(password: user.password)
                return try UserRegistInfo.query(on: req).filter(\.username == user.username).filter(\.password == user.password).first().map(){
                    userRegisterInfo in
                    if userRegisterInfo == nil {
                        return ResponseModel<AccessToken>(status: -1, message: "用户名或密码错误", data: nil)
                    }
                    let accessToken = AccessToken.login(user: user)
                    return ResponseModel<AccessToken>(status: 0, message: "登陆成功", data: accessToken)
                }
            }
        }
    }
    
    /// 用户注销
    func logout(req : Request)throws -> Future<ResponseModel<String> > {
        return try req.content.decode(RequestModel<String>.self).flatMap(){
            requestBody in
            return try requestBody.JudgeSercretKey(req: req).map(){ result in
                if !result {
                    return ResponseModel<String>(status: -3, message: secretKeyError, data: nil)
                }
                if AccessToken.logout(accessToken:requestBody.accessToken!) {
                    return ResponseModel<String>(status: 0, message: "注销成功", data: nil)
                }else {
                    return ResponseModel<String>(status: -1, message: "注销失败", data: nil)
                }
                
            }
        }
    }
    
}
