//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Neri Quiroz on 11/19/20.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}
