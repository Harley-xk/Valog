//
//  IPGeoLocation.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation

struct GeoLocation: Codable {
    
    // "AS4837 CHINA UNICOM China169 Backbone",
//    var `as`: String
    
    // "苏州",
    var city: String?
    
    // "中国",
    var country: String?
    
    // "CN",
    var countryCode: String?
    
    // "China Unicom Jiangsu Province Network",
    var isp: String?
    
    // 31.3041,
    var lat: Double?
    
    // 120.5954,
    var lon: Double?
    
    // "",
    var org: String?
    
    // "157.0.158.2",
    var query: String
    
    // "JS",
    var region: String?
    
    // "江苏省",
    var regionName: String?
    
    // "success",
    var status: String
    
    // "Asia/Shanghai",
    var timezone: String?
    
    // ""
    var zip: String?
    
    var message: String?
    
    var brief: String {
        if status == "success", let country = country, let city = city {
            return country + ", " + city
        }
        return message ?? "<no result>"
    }
    
}
