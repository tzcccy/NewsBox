//
//  VerifyEmail.swift
//  App
//
//  Created by SuperT on 2018/5/10.
//

import Foundation
import Vapor
import SwiftSMTP

struct PUBGBoxEmail : Content{
    var email       :   String
    var verifycode  :   String?
}


fileprivate var emailDic = Dictionary<String,String>()
/// Configure mail Server
fileprivate let smtp = SMTP(hostname: "smtp.163.com",     // SMTP server address
                            email: "pubgnewsbox@163.com",     // username to login
                            password: "pubgnewsbox520")           // password to login


fileprivate let PUBGNewsBoxMailAddress = Mail.User(name: "PUBG新闻盒子", email: "pubgnewsbox@163.com")
/// check verify code
extension PUBGBoxEmail{
    func checkVerifyCode() ->Bool{
        guard let verifyCode = emailDic[self.email] else {
            return false
        }
        guard let customVerifyCode = self.verifycode else{
            return false
        }
        if verifyCode == customVerifyCode {
            emailDic[self.email] = nil
            return true
        }
        return false
    }
}

extension PUBGBoxEmail{
    static func sendEmailCode(req : Request, email : String ) -> Future<Bool>{
        
        var verifyCode = emailDic[email]
        
        if verifyCode == nil{
            verifyCode = RandomString.sharedInstance.getRandomStringOfLength(length: 4)
        }
        ///catch result and return
        let userMail = Mail.User(email: email)
        
        let mail = Mail(
            from: PUBGNewsBoxMailAddress,
            to: [userMail],
            subject: "欢迎注册PUBG新闻盒子",
            text: "您本次注册的验证码为：\(verifyCode!)"
        )
        let result = req.eventLoop.newPromise(Bool.self)
        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
                result.succeed(result: false)
            }else{
                emailDic[email] = verifyCode!
                result.succeed(result: true)
            }
        }
        
        return result.futureResult
    }
    
}



/// 随机字符串生成
class RandomString {
    let str = "1234567890"
    
    /**
     生成随机字符串,
     
     - parameter length: 生成的字符串的长度
     
     - returns: 随机生成的字符串
     */
    func getRandomStringOfLength(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(str.count)))
            ranStr.append(str[str.index(str.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    private init() { }
    static let sharedInstance = RandomString()
}


