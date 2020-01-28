//
//  Funtionalities.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-13.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import Foundation
import UIKit
//Installing Alamofire (4.9.1)
//Installing SwiftyJSON (5.0.0)

let THEMOVIEDB_URL = "https://www.themoviedb.org/"
let IMAGE_BASE_URL = "https://image.tmdb.org/t/p/original"

#warning("Put API KEY below")
let API_KEY = ""
let BACKGROUND_COLOR = UIColor(red: 1/255, green: 210/255, blue: 119/255, alpha: 1)

func getDiscoverMovieURL(page:Int) -> String {
    return "https://api.themoviedb.org/3/discover/movie?api_key=\(API_KEY)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)"
}
func getSearchMovieURL(query:String,page:Int) -> String {
    return "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&language=en-US&query=\(query)&page=\(page)&include_adult=false"
}

