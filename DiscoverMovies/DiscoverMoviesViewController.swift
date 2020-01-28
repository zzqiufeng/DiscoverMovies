//
//  DiscoverMoviesViewController.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-21.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//global array storing user's favorite movies
var favoriteMovies: [Int] = []

class DiscoverMoviesViewController: UIViewController{

    var moviesDiscovered = [Movie]()
    var moviesInfoDiscovered = DiscoverResult(page: 0, total_results: 0, total_pages: 0)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalResults: UILabel!
    @IBOutlet weak var pageInfo: UILabel!
    
    var currentPage = 1
    var rowSelected = 0
    var isRefreshing = false
    var currentCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Discover Movies"
        view.backgroundColor = BACKGROUND_COLOR
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "movieCell")
        tableView.register(UINib(nibName: "RefreshTableViewCell",bundle:nil), forCellReuseIdentifier: "refreshCell")
        //
        
        if isInternetAvailable() {
            discoverMovies()
        } else {
            let alertController = UIAlertController(title: "No Internet Connection.", message: "You need a Internet connection to use this app.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        //print("All reviews: \(ReviewMovies.shared.reviews)")
    }
    
    func discoverMovies() {
        isRefreshing = false
        let urlString = getDiscoverMovieURL(page: currentPage)
        //print(urlString)
        Alamofire.request(urlString).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
               // Handle network error
                if swiftyJsonVar["status_code"].intValue == 11 {
                    let alertController = UIAlertController(title: "Internal error: Something went wrong, contact TMDb.", message: nil, preferredStyle: .alert)                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    //way 1 in a viewcontroller
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.moviesInfoDiscovered = DiscoverResult(page: swiftyJsonVar["page"].intValue, total_results: swiftyJsonVar["total_results"].intValue, total_pages: swiftyJsonVar["total_pages"].intValue)
                    let results = swiftyJsonVar["results"].arrayValue
                    for one in results {
                        let genre_idsArray = one["genre_ids"].arrayValue
                        var ids: [Int] = []
                        for oneID in genre_idsArray {
                            ids.append(oneID.intValue)
                        }
                        let oneMovie = Movie(popularity: one["popularity"].doubleValue, vote_count: one["vote_count"].intValue, video: one["video"].boolValue, poster_path: one["poster_path"].stringValue, id: one["id"].intValue, adult: one["adult"].boolValue, backdrop_path: one["backdrop_path"].stringValue, original_language: one["original_language"].stringValue, original_title: one["original_title"].stringValue, genre_ids: ids, title: one["title"].stringValue, vote_average: one["vote_average"].intValue, overview: one["overview"].stringValue, release_date: one["release_date"].stringValue)
                        self.moviesDiscovered.append(oneMovie)
                    }
                    DispatchQueue.main.async {
                        self.currentCount = self.moviesDiscovered.count
                        print("First discover \(self.currentCount) movies.")
                        self.tableView.reloadData()
                        self.totalResults.text = String(self.moviesInfoDiscovered.total_results)
                        self.pageInfo.text = String(self.moviesInfoDiscovered.page) + " / " + String(self.moviesInfoDiscovered.total_pages)
                    }
                }
            }
        }
    }
    
    func loadMoreMovies(ofPage page:Int){
        if !self.isRefreshing {
            print("loading \(page)")
            isRefreshing = true
            let urlString = getDiscoverMovieURL(page: currentPage)
            Alamofire.request(urlString).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                   // Handle network error
                    if swiftyJsonVar["status_code"].intValue == 11 {
                        let alertController = UIAlertController(title: "Internal error: Something went wrong, contact TMDb.", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.moviesInfoDiscovered = DiscoverResult(page: swiftyJsonVar["page"].intValue, total_results: swiftyJsonVar["total_results"].intValue, total_pages: swiftyJsonVar["total_pages"].intValue)
                        let results = swiftyJsonVar["results"].arrayValue
                        for one in results {
                            let genre_idsArray = one["genre_ids"].arrayValue
                            var ids: [Int] = []
                            for oneID in genre_idsArray {
                                ids.append(oneID.intValue)
                            }
                            let oneMovie = Movie(popularity: one["popularity"].doubleValue, vote_count: one["vote_count"].intValue, video: one["video"].boolValue, poster_path: one["poster_path"].stringValue, id: one["id"].intValue, adult: one["adult"].boolValue, backdrop_path: one["backdrop_path"].stringValue, original_language: one["original_language"].stringValue, original_title: one["original_title"].stringValue, genre_ids: ids, title: one["title"].stringValue, vote_average: one["vote_average"].intValue, overview: one["overview"].stringValue, release_date: one["release_date"].stringValue)
                            self.moviesDiscovered.append(oneMovie)
                        }
                       // print("Movies Array\n\n\(self.moviesDiscovered)")
                        DispatchQueue.main.async {
                            print("Found again \(self.moviesDiscovered.count - self.currentCount) movies.")
                            self.currentCount = self.moviesDiscovered.count
                            print("Now there are \(self.currentCount) movies.")
                            self.tableView.reloadData()
                            self.totalResults.text = String(self.moviesInfoDiscovered.total_results)
                            self.pageInfo.text = String(self.moviesInfoDiscovered.page) + " / " + String(self.moviesInfoDiscovered.total_pages)
                            self.isRefreshing = false
                        }
                    }
                }
            }
        }
    }
    
    func resetGlobalMoviesDiscovered() {
        moviesDiscovered = []
        moviesInfoDiscovered = DiscoverResult(page: 0, total_results: 0, total_pages: 0)
    }
    
    
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromDiscover" {            
            let viewController = segue.destination as? OneMovieViewController
            viewController?.oneMovie = moviesDiscovered[rowSelected]
        }
    }
    

}

// MARK: - tableView operations
extension DiscoverMoviesViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return moviesDiscovered.count
        } else {
            return 1
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieTableViewCell
            cell.setMovie(movie: moviesDiscovered[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "refreshCell", for: indexPath) as! RefreshTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(107)
        } else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("go to one movie")
        rowSelected = indexPath.row
        performSegue(withIdentifier: "fromDiscover", sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height) && !isRefreshing {
            currentPage += 1
            loadMoreMovies(ofPage: currentPage)
        }
    }
    
}
