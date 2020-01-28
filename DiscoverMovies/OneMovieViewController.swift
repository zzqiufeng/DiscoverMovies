//
//  OneMovieViewController.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-21.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit


class OneMovieViewController: UIViewController {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    var screenSize:CGRect = UIScreen.main.bounds
    var screenWidth = CGFloat(0)
    var screenHeight = CGFloat(0)
    var statusBarHeight = CGFloat(0)
    var navHeight = CGFloat(0)
    var tabHeight = CGFloat(0)
    let edge = CGFloat(0)
    let gap = CGFloat(10)
   // let contentScrollView = UIScrollView()
    let backdropWidthHeightRatio = CGFloat(2160.0 / 3840.0)
    var oneMovie : Movie?
    let backdropImageView = UIImageView()
    var backdropImage:UIImage?
    var isImageObtained = false
    var isFirstRun = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        print("Show one movie.")
        view.backgroundColor = BACKGROUND_COLOR
        if oneMovie != nil {
            print(oneMovie!.poster_path)
            print(oneMovie!.backdrop_path)
        }
        getScreenUIdata()
        
       // addContentScrollowView()
        movieTitle.text = oneMovie?.title
        movieTitle.textAlignment = .left
        movieTitle.adjustsFontSizeToFitWidth = true
        addMovieInfoToContentScrollView()
        showFavorite()
    }
    
    @IBAction func writeReview(_ sender: Any) {
        performSegue(withIdentifier: "review", sender: nil)
    }
       
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isFirstRun {
            print("viewDidLayoutSubviews called")
            let oldScreenWidth = screenWidth
            screenWidth = screenHeight
            screenHeight = oldScreenWidth
            for view in contentScrollView.subviews {
                view.removeFromSuperview()
            }
            addMovieInfoToContentScrollView()
            if isImageObtained{
                backdropImageView.image = backdropImage
            }
        }
        
    }
   
    func showFavorite(){
        if oneMovie != nil {
            if FavoriteMovies.shared.isFavorite(id: oneMovie!.id) {
                favoriteButton.setImage(UIImage.init(named: "favorited40.png"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage.init(named: "whiteHeart40.png"), for: .normal)
            }
            print(" there are \(FavoriteMovies.shared.movies.count as Any) favorite movies.")
        }
    }
    
    @IBAction func setFavorite(_ sender: Any) {
        if oneMovie != nil {
            if FavoriteMovies.shared.isFavorite(id: oneMovie!.id) {
                FavoriteMovies.shared.removeFavorite(id: oneMovie!.id)
                favoriteButton.setImage(UIImage.init(named: "whiteHeart40.png"), for: .normal)
                print(" there are \(FavoriteMovies.shared.movies.count as Any) favorite movies after remove favorite.")
            } else {
                FavoriteMovies.shared.addFavorite(movie: oneMovie!)
                favoriteButton.setImage(UIImage.init(named: "favorited40.png"), for: .normal)
                print(" there are \(FavoriteMovies.shared.movies.count as Any) favorite movies after set favorite.")
            }
        }
    }
    
    func getScreenUIdata(){
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        statusBarHeight = UIApplication.shared.statusBarFrame.height

        navHeight = self.navigationController != nil ? self.navigationController!.navigationBar.frame.size.height : CGFloat(0)
        if self.tabBarController != nil {
            if !((self.tabBarController?.tabBar.isHidden)!) {
                tabHeight = self.tabBarController != nil ? self.tabBarController!.tabBar.frame.size.height : CGFloat(0)
            }
        }
        print(" screen size width \(screenWidth)")
        print(" screen size height \(screenHeight)")
        print(" status bar height \(statusBarHeight)")
        print(" nav height \(String(describing: navHeight))   \n tab height \(String(describing: tabHeight))")
    }
    
    func addContentScrollowView(){
        let contentScrollViewY = statusBarHeight +  movieTitle.frame.origin.y + movieTitle.frame.height + gap
        contentScrollView.frame = CGRect(x: edge, y: contentScrollViewY, width: screenWidth, height: screenHeight - contentScrollViewY)
        contentScrollView.backgroundColor = .white
        view.addSubview(contentScrollView)
    }
    
    func addMovieInfoToContentScrollView() {
        var scrollViewHeight = CGFloat(0)
        let labelHeight = CGFloat(40)
        //
        let backdropImageHeight = screenWidth * backdropWidthHeightRatio
        backdropImageView.frame = CGRect(x: edge, y: edge, width: screenWidth, height: backdropImageHeight)
        scrollViewHeight = scrollViewHeight + backdropImageHeight + gap
        //
        scrollViewHeight += gap
        let popularityLabel = UILabel(frame: CGRect(x: edge * 2, y: scrollViewHeight, width: (screenWidth/2 - edge*2), height: labelHeight))
        popularityLabel.text = " Popularity:"
        let popularityValueLabel = UILabel(frame: CGRect(x: (screenWidth/2 + edge), y: scrollViewHeight, width: (screenWidth/2 - edge*2), height: labelHeight))
        popularityValueLabel.text = String(format: "%f", oneMovie?.popularity ?? 0.0)
        //
        scrollViewHeight += (gap * 3)
        let releaseDateLabel = UILabel(frame: CGRect(x: edge * 2, y: scrollViewHeight, width: (screenWidth/2 - edge*2), height: labelHeight))
        releaseDateLabel.text = " Release date:"
        let releaseDateValueLabel = UILabel(frame: CGRect(x: (screenWidth/2 + edge), y: scrollViewHeight, width: (screenWidth/2 - edge*2), height: labelHeight))
        releaseDateValueLabel.text = oneMovie?.release_date
        //
        scrollViewHeight += (gap * 3)
        let overviewLabel = UILabel(frame: CGRect(x: edge * 2, y: scrollViewHeight, width: (screenWidth/2 - edge*2), height: labelHeight))
        overviewLabel.text = " Overview:"
        //
        scrollViewHeight += (gap * 3)
        let reviewTextView = UITextView(frame: CGRect(x: edge * 2, y: scrollViewHeight, width: (screenWidth - edge*4), height: labelHeight * 6))
        scrollViewHeight += labelHeight * 6
        reviewTextView.text = oneMovie?.overview
        reviewTextView.isEditable = false
        reviewTextView.font = UIFont.systemFont(ofSize: 20)
        //
        scrollViewHeight += (gap * 2)
        contentScrollView.contentSize = CGSize(width: screenWidth, height: scrollViewHeight)
        //
        contentScrollView.addSubview(backdropImageView)
        if !isImageObtained {
            addImage()
        }
        contentScrollView.addSubview(popularityLabel)
        contentScrollView.addSubview(popularityValueLabel)
        contentScrollView.addSubview(releaseDateLabel)
        contentScrollView.addSubview(releaseDateValueLabel)
        contentScrollView.addSubview(overviewLabel)
        contentScrollView.addSubview(reviewTextView)
        //
        isFirstRun = false
    }
    
    func addImage() {
        let backdropURL = IMAGE_BASE_URL + oneMovie!.backdrop_path
        guard let imageURL = URL(string: backdropURL) else {
            print("imageURL  invalid")
            return
        }
        DispatchQueue.global().async {[weak self] in
            guard let imageData = try? Data(contentsOf: imageURL) else {
                print("cannot download image.")
                DispatchQueue.main.async {
                    let noImageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                    noImageLabel.textAlignment = .center
                    noImageLabel.center = (self?.backdropImageView.center)!
                    noImageLabel.text = "No Backdrop Image."
                    self?.backdropImageView.addSubview(noImageLabel)
                }
                return
            }
            print("image obtained from server. \(imageData)")
            self?.backdropImage = UIImage(data: imageData)
            DispatchQueue.main.async {
                self?.backdropImageView.image = self?.backdropImage
                self?.isImageObtained = true
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("DEvice Oritation changed.")
        coordinator.animate(alongsideTransition: { context in
            if UIApplication.shared.statusBarOrientation.isLandscape {
                // activate landscape changes
                print("Now iOS is in isLandscape")
            } else {
                // activate portrait changes
                print("Now iOS is in isPortrait")
            }
        })
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "review" {
            if oneMovie != nil {
                let viewController = segue.destination as? AddReviewViewController
                viewController?.reviewId = oneMovie!.id
            }            
        }
    }
    

}
