//
//  ImageModel.swift
//  TestGif
//
//  Created by Michael Hughes on 1/31/18.
//  Copyright © 2018 Michael Hughes. All rights reserved.
//

import Foundation

struct ImageModel {
    
    var imageUrl: String!
    var location: String!
    var weather: String!
    
    init(imageUrl: String, location: String, weather: String) {
        self.imageUrl = imageUrl
        self.location = location
        self.weather = weather
    }
    
}
