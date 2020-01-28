//
//  DataStructure.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-20.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import Foundation
import UIKit


struct Movie {
    var popularity:Double
    var vote_count:Int
    var video:Bool
    var poster_path:String
    var id:Int
    var adult:Bool
    var backdrop_path:String
    var original_language:String
    var original_title:String
    var genre_ids:[Int]
    var title:String
    var vote_average:Int
    var overview:String
    var release_date:String
    init(popularity:Double, vote_count:Int,video:Bool,poster_path:String,id:Int,adult:Bool,backdrop_path:String,original_language:String,original_title:String,genre_ids:[Int],title:String,vote_average:Int,overview:String,release_date:String) {
        self.popularity = popularity
        self.vote_count = vote_count
        self.video = video
        self.poster_path = poster_path
        self.id = id
        self.adult = adult
        self.backdrop_path = backdrop_path
        self.original_language = original_language
        self.original_title = original_title
        self.genre_ids  = genre_ids
        self.title = title
        self.vote_average = vote_average
        self.overview = overview
        self.release_date = release_date
    }
}

struct DiscoverResult {
    var page:Int
    var total_results:Int
    var total_pages:Int
    init(page:Int,total_results:Int,total_pages:Int) {
        self.page = page
        self.total_results = total_results
        self.total_pages = total_pages
    }
}

struct Review {
    var reviewId:Int
    var starRate:Int
    var title:String
    var review:String
    var photo:UIImage?
}

typealias RateStar = (rate:Int,set:Bool)
