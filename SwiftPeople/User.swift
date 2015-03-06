//
//  User.swift
//  SwiftPeople
//
//  Created by Dalton Cherry on 3/6/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import Foundation
import JSONJoy
import SwiftHTTP

struct User: JSONJoy {
    let name: Name
    let picture: Picture
    //computed property to return a full name: "John Doe".
    var displayName: String { return "\(name.first) \(name.last)" }
    
    //implement the JSONJoy protocol
    init(_ decoder: JSONDecoder) {
        name = Name(decoder["name"])
        picture = Picture(decoder["picture"])
    }
    
    //fetch the random users from the network
    static func getUsers(finished:((Array<User>) -> Void)) {
        let task = HTTPTask()
        task.responseSerializer = JSONResponseSerializer()
        task.GET("http://api.randomuser.me", parameters: ["results": "30"], success: { (response: HTTPResponse) in
            if let data = response.responseObject as? NSDictionary {
                var collect = Array<User>()
                //get a decoder of the data
                let decoder = JSONDecoder(data)
                //check the array is valid and loop through the array
                if let arr = decoder["results"].array {
                    for subDecoder in arr {
                        //flatten the json
                        let user = subDecoder["user"]
                        if user.error == nil {
                            collect.append(User(user))
                        }
                    }
                }
                //move to the main thread as we are done with our processing
                dispatch_async(dispatch_get_main_queue(), {
                    finished(collect)
                })
            }
            }, failure: { (error: NSError, response: HTTPResponse?) -> Void in
            println("failed to get random users: \(error)")
        })
    }
    
}

//represents the User's name
struct Name: JSONJoy {
    let first: String
    let last: String
    
    //JSONJoy init method
    init(_ decoder: JSONDecoder) {
        first = safeString(decoder,"first")
        last = safeString(decoder,"last")
    }
}

//represents the User's picture
struct Picture: JSONJoy {
    let thumbnail: String
    let small: String
    let medium: String
    let large: String
    
    //JSONJoy init method
    init(_ decoder: JSONDecoder) {
        thumbnail = safeString(decoder,"thumbnail")
        small = safeString(decoder,"small")
        medium = safeString(decoder,"medium")
        large = safeString(decoder,"large")
    }
}

//unwrap and read a string safely
func safeString(decoder: JSONDecoder, key: String) -> String {
    if let str = decoder[key].string {
        return str
    }
    return ""
}

