//
//  Error.swift
//  VirtualTourist
//
//  Created by Yoyo Chan on 2021-07-08.
//

import Foundation
struct Error: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension Error: LocalizedError{
    var errorDescription: String?{
        return message
    }
}
