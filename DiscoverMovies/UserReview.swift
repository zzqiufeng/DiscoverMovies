//
//  UserReview.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-23.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import Foundation

final class UserReview {
    static let shared = UserReview()
    var reviews = [Review]()
    private init(){}
    
    func addReview(review:Review){
        reviews.append(review)
    }
    
    func getReview(reviewId id:Int) -> Review{
        return reviews[id]
    }
    
    func isReviewExisted(forReviewId id:Int) -> Bool {
        if (reviews.firstIndex(where: {$0.reviewId == id})) != nil {
            return true
        }
        return false
    }
}
