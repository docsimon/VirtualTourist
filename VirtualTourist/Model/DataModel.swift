//
//  DataModel.swift
//  VirtualTourist
//
//  Created by doc on 07/05/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation

// Data model for encoding/deconding json files and support data

struct ErrorData{
    let errorTitle: String
    let errorMsg: String
}


struct Flickr: Decodable {
    let photos: Gallery
}

struct Gallery: Decodable {
    let photo: [PhotoF]
}

struct PhotoF: Decodable {
    let url_m: String
}
