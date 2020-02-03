//
//  PublicContent.swift
//  App
//
//  Created by Harley-xk on 2020/1/30.
//

import Foundation
import Vapor

protocol PublicContent {
    
    associatedtype PublicType: Content
    
    func makePublic() -> PublicType
    
}
