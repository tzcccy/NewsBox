//
//  UserController.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Foundation
import Vapor
import FluentMySQL

fileprivate let paramError = "请求参数错误"
fileprivate let secretKeyError = "App鉴权错误"

/// 1.检查客户端密钥是否正确
/// ```
/// try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).map(){result in
/// if !result {
///    return ResponseModel<String>(status: -3, message: secretKeyError, data: nil)
/// }
/// ```
/// 2.检查用户登陆状态
///```
///let loginStatus = AccessToken.checkAccessToken(accessToken: requestBody.accessToken)
///if .ok != loginStatus {
///    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -1, message: loginStatus.rawValue, data: nil))
///}
///```
final class UserController{

    /// 用户注册
    func register(req : Request)throws -> Future<ResponseModel<UserRegistInfo> >{
        return try req.content.decode(RequestModel<UserRegistInfo>.self).flatMap(){ requestBody in
            
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).flatMap(){result in
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
                            return ResponseModel<UserRegistInfo>(status: 0, message: "注册成功", data: nil)
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
            
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).flatMap(){result in
                if !result {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -3, message: secretKeyError, data: nil))
                }
                
                guard let mail = requestBody.data else {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -2, message: paramError, data: nil))
                }
                return PUBGBoxEmail.sendEmailCode(req: req, email: mail.email).map(){ sendEmailResult in
                    if sendEmailResult {
                        return ResponseModel<String>(status: 0, message: "发送验证码成功", data: nil)
                    }
                    return ResponseModel<String>(status: -1, message: "发送验证码失败", data: nil)
                }
                
            }
            
            
            
            
        }
    }
    
    /// 用户登陆
    func login(req : Request)throws -> Future<ResponseModel<AccessToken> >{
        return try req.content.decode(RequestModel<UserLoginInfo>.self).flatMap(){requestBody in
            
            
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).flatMap(){result in
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
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).map(){result in
                
                //1.检查客户端密钥是否正确
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
    
    /// 更新用户信息
    func updateUserInfo(req : Request) throws -> Future<ResponseModel<String> >{
        return try req.content.decode(RequestModel<UserInfo>.self).flatMap(){ requestBody in
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).flatMap(){result in
                if !result {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -3, message: secretKeyError, data: nil))
                }
                
                let loginStatus = AccessToken.checkAccessToken(accessToken: requestBody.accessToken)
                if .ok != loginStatus {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -1, message: loginStatus.rawValue, data: nil))
                }
                
                
                
                guard let username = AccessToken.getUserNameByAccessToken(accessToken: requestBody.accessToken!) else{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -4, message: "用户未登录", data: nil))
                }
                guard let userInfo = requestBody.data else {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: 0, message: "成功", data: nil))
                }
                userInfo.username = username
                return try UserInfo.query(on: req).filter(\UserInfo.username == username).first().flatMap(){ orginUser in
                    guard let orginUser = orginUser else{
                        return userInfo.create(on: req).transform(to: ResponseModel<String>(status: 0, message: "成功", data: nil))
                    }
                    return userInfo.mergeUser(orginUser: orginUser).update(on: req).transform(to: ResponseModel<String>(status: 0, message: "成功", data: nil))
                }
            }

        }
    }
    
    /// 更新用户头像
    func updateUserHeadPicture(req : Request) throws -> Future<ResponseModel<String> >{
        return try req.content.decode(RequestModel<File>.self).flatMap(){ requestBody in
            /// 判断app密钥
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey,req: req).flatMap(){result in
                if !result {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -3, message: secretKeyError, data: nil))
                }
                /// 判断用户登陆状态
                let loginStatus = AccessToken.checkAccessToken(accessToken: requestBody.accessToken)
                if .ok != loginStatus {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -1, message: loginStatus.rawValue, data: nil))
                }
                /// 处理本逻辑
                guard let file = requestBody.data else {
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status: -2, message: paramError, data: nil))
                }
                //获取用户信息
                let username = AccessToken.getUserNameByAccessToken(accessToken: requestBody.accessToken!)!
                
                return try UserInfo.query(on: req).filter(\UserInfo.username == username).first().flatMap(){queryResult in
                    
                    //删除已存在的头像
                    let filePath:String = try req.make(DirectoryConfig.self).workDir + "Public" + "/headpic"
                    let fileManager = FileManager()
                    var userInfo = queryResult
                    
                    if userInfo == nil {
                        userInfo = UserInfo()
                        userInfo?.username = username
                    }
                    
                    
                    if userInfo?.headpic != nil {
                        if fileManager.fileExists(atPath: filePath + "/" + userInfo!.headpic!) {
                            try fileManager.removeItem(atPath: filePath + "/" + userInfo!.headpic!)
                        }
                    }
                    
                    userInfo?.headpic = username + "." + file.filename.split(separator: ".").map(String.init)[1]
                    try file.data.write(to: URL(fileURLWithPath: filePath + "/" + userInfo!.headpic!))
                    if queryResult == nil {
                        return userInfo!.create(on: req).transform(to: ResponseModel<String>(status: 0, message: "成功", data: nil))
                    }else {
                        return userInfo!.update(on: req).transform(to: ResponseModel<String>(status: 0, message: "成功", data: nil))
                    }
                    
                }
            }
        }
    }
    
}
