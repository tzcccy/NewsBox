//
//  VerifyEmail.swift
//  App
//
//  Created by SuperT on 2018/5/10.
//

import Foundation
import Vapor
import MailCore


struct PUBGBoxEmail : Content{
    var email       :   String
    var verifycode  :   String?
}


fileprivate var emailDic = Dictionary<String,String>()


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
            return true
        }
        return false
    }
}

extension PUBGBoxEmail{
    static func sendEmailCode(_ email : String,_ req : Request)throws -> Future<Bool>{
        
        var verifyCode = emailDic[email]
        
        if verifyCode == nil{
            verifyCode = RandomString.sharedInstance.getRandomStringOfLength(length: 4)
            emailDic[email] = verifyCode!
        }
        
        
        let mail = Mailer.Message(from: "pubgnewsbox@163.com", to: email, subject: "欢迎注册PUBG新闻盒子", text: "您本次注册的验证码为\(verifyCode!)", html:nil)
        return try req.mail.send(mail).map(to: Bool.self) { mailResult in
            print(mailResult)
            // ... Return your response for example
            return true
        }
        
        ///catch result and return
        
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


