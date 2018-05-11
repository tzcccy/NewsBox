//
//  PUBGNewsBoxTools.swift
//  App
//
//  Created by SuperT on 2018/5/11.
//

import Foundation
import Crypto

func encryptPassword(password : String) throws -> String{
    return try SHA1.hash(password).hexEncodedString()
}
