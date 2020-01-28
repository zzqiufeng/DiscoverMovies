//
//  ReviewMovies.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-23.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import Foundation

final class ReviewMovies {
    
    static let shared = ReviewMovies()
    var reviews = [Review]()
    private init(){}
   
    func addReview(review:Review){
        if !isReviewExisted(forId: review.reviewId){
           reviews.append(review)
        }
    }
    
    func updateReview(review:Review) {
        if let index = reviews.firstIndex(where: {$0.reviewId == review.reviewId}) {
            reviews[index] = review
        }
    }
       
    func getAllReview() -> [Review]?{
       return reviews
    }
       
    func getReview(withId id:Int) -> Review?{
       var oneReview:Review?
       if let index = reviews.firstIndex(where: {$0.reviewId == id}) {
           oneReview = reviews[index]
       }
       return oneReview
    }
   
    func isReviewExisted(forId id:Int) -> Bool{
       var existed = false
       if (reviews.firstIndex(where: {$0.reviewId == id})) != nil {
           existed = true
       }
       return existed
    }
}
