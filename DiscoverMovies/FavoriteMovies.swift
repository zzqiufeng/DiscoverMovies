//
//  FavoriteMovies.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-22.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import Foundation



final class FavoriteMovies {
    static let shared = FavoriteMovies()
    var movies = [Movie]()
    private init(){}
    
    func addFavorite(movie:Movie){
        movies.append(movie)
    }
    
    func getAllFavorite() -> [Movie]?{
        return movies
    }
    
    func removeFavorite(id:Int) -> Bool{
        var removed = false
        if let index = movies.firstIndex(where: {$0.id == id}) {
            movies.remove(at: index)
            removed = true
        }
        return removed
    }
    
    func isFavorite(id:Int) -> Bool{
        var favorite = false
        if (movies.firstIndex(where: {$0.id == id})) != nil {
            favorite = true
        }
        return favorite        
    }
}
