//
//  AccessTokenManager.swift
//  App
//
//  Created by SuperT on 2018/5/11.
//

import Foundation
import Vapor
import Crypto


enum AccessTokenStatusEnum : String {
    case ok = "成功"
    case timeout = "过期"
    case unlogin = "未登录"
}


/// 用户accessToken缓存
fileprivate var accessTokenCache = Dictionary<String,AccessToken>()
/// username to accesstoken
fileprivate var usernameCache = Dictionary<String,String>()

func getAccessTokenCache() -> Dictionary<String,AccessToken> {
    return accessTokenCache
}
func getUsernameCache()->Dictionary<String,String> {
    return usernameCache
}

final class AccessToken : Content{
    var username        :   String
    var accessToken     :   String
    var createTime      :   Int
    var expireIn        :   Int
    
    init(username : String, createTime : Int = Int(Date().timeIntervalSince1970), expireIn : Int = 24*60*60){
        self.username = username
        self.createTime = createTime
        self.expireIn = expireIn
        do {
            self.accessToken = try MD5.hash(username + String(createTime)).hexEncodedString()
        } catch {
            self.accessToken = username + String(createTime)
        }
    }
    
}



extension AccessToken {
    
    /// 检查是否过期
    fileprivate func checkTimeOut() -> Bool {
        let nowInterval = Int(Date().timeIntervalSince1970)
        if nowInterval > createTime + expireIn {
            return true
        }else {
            return false
        }
    }
    
    
    /// 检查accesstoken状态
    public static func checkAccessToken(accessToken : String?) -> AccessTokenStatusEnum {
        
        guard let accessToken = accessToken else {
            return .unlogin
        }
        
        guard let tokenStruct = accessTokenCache[accessToken] else {
            return .unlogin
        }
        // 计算是否超时
        if tokenStruct.checkTimeOut() {
            // 超时
            return .timeout
        }
        return .ok
    }
    
    
    /// 登陆操作
    public static func login(user : UserLoginInfo) -> AccessToken {
        let accessTokenStruct = AccessToken(username: user.username)
        /// 清空之前的登陆信息
        let oldaccessToken = usernameCache[user.username]
        if oldaccessToken != nil {
            accessTokenCache[oldaccessToken!] = nil
            usernameCache[user.username] = nil
        }
        
        /// 第一步，缓存username to accesstoken
        usernameCache[user.username] = accessTokenStruct.accessToken
        /// 第二步，缓存accesstoken struct
        accessTokenCache[accessTokenStruct.accessToken] = accessTokenStruct
        
        return accessTokenStruct
    }
    
    /// 注销操作
    public static func logout(accessToken : String) -> Bool{
        guard let username = accessTokenCache[accessToken]?.username else {
            //TODO:记录日志
            return false
        }
        //清除username to accesstoken缓存
        usernameCache[username] = nil
        //清除accesstoken缓存
        accessTokenCache[accessToken] = nil
        return true
    }
    
    /// 刷新操作
    public static func refreshAccessToken(accessToken : String) -> AccessToken?{
        guard let username = accessTokenCache[accessToken]?.username else {
            // 不存在该用户
            return nil
        }
        // 清除accessToken缓存
        accessTokenCache[accessToken] = nil
        
        let newAccessToken = AccessToken(username: username)
        // 刷新username缓存
        usernameCache[username] = newAccessToken.accessToken
        // 刷新accessToken缓存
        accessTokenCache[newAccessToken.accessToken] = newAccessToken
        
        return newAccessToken
    }
    
    
    /// 获取accessToken对应用户信息
    public static func getUserNameByAccessToken(accessToken : String) -> String? {
        return accessTokenCache[accessToken]?.username
    }
}




