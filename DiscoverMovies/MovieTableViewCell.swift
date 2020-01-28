//
//  MovieTableViewCell.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-22.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var popularity: UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func setMovie(movie:Movie) {
        let posterURL = IMAGE_BASE_URL + movie.poster_path
        guard let imageURL = URL(string: posterURL) else {
            print("imageURL  invalid")
            return
        }
        showActivityIndicatory()
        DispatchQueue.global().async {[weak self] in
            guard let imageData = try? Data(contentsOf: imageURL) else {
                return
            }
            let image = UIImage(data: imageData)
            if let reducedImageData = image?.jpeg(.low)
            {
                let reducedImage = UIImage(data: reducedImageData)
                DispatchQueue.main.async {
                    self?.posterImage.image = reducedImage//image
                    self?.hideActivityIndicator()
                }
            } else {
                let reducedImage = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self?.posterImage.image = reducedImage//image
                    self?.hideActivityIndicator()
                }
            }
        }
        movieTitle.text = movie.original_title
        releaseDate.text = movie.release_date
        releaseDate.textAlignment = .right
        releaseDate.adjustsFontSizeToFitWidth = true
        popularity.text = "Popularity: " + String(movie.popularity)
        popularity.textAlignment = .right
        popularity.adjustsFontSizeToFitWidth = true
    }
    func showActivityIndicatory(){
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicator.center = posterImage.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style =
            UIActivityIndicatorView.Style.whiteLarge
        posterImage.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
