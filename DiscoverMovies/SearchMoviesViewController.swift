//
//  SearchMoviesViewController.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-22.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchMoviesViewController: UIViewController {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //
    var moviesInfoSearched = DiscoverResult(page: 0, total_results: 0, total_pages: 0)
    var moviesSearched = [Movie]()
    var queryContent = String()
    var rowSelected = 0
    var currentPage = 1
    var currentCount = 0
    var isRefreshing = false
    var isSearchContentInput = false
    var isFirstTimeSearch = true
    var isfirstSearchFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search Movies"
        view.backgroundColor = BACKGROUND_COLOR
        SearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadMoreMovies(ofPage page:Int){
        if !self.isRefreshing {
            print("loading page \(page)")
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
                        self.moviesInfoSearched = DiscoverResult(page: swiftyJsonVar["page"].intValue, total_results: swiftyJsonVar["total_results"].intValue, total_pages: swiftyJsonVar["total_pages"].intValue)
                        let results = swiftyJsonVar["results"].arrayValue
                        for one in results {
                            let genre_idsArray = one["genre_ids"].arrayValue
                            var ids: [Int] = []
                            for oneID in genre_idsArray {
                                ids.append(oneID.intValue)
                            }
                            let oneMovie = Movie(popularity: one["popularity"].doubleValue, vote_count: one["vote_count"].intValue, video: one["video"].boolValue, poster_path: one["poster_path"].stringValue, id: one["id"].intValue, adult: one["adult"].boolValue, backdrop_path: one["backdrop_path"].stringValue, original_language: one["original_language"].stringValue, original_title: one["original_title"].stringValue, genre_ids: ids, title: one["title"].stringValue, vote_average: one["vote_average"].intValue, overview: one["overview"].stringValue, release_date: one["release_date"].stringValue)
                            self.moviesSearched.append(oneMovie)
                        }
                        DispatchQueue.main.async {
                            print("Found again \(self.moviesSearched.count - self.currentCount) movies.")
                            self.currentCount = self.moviesSearched.count
                            print("Now there are \(self.currentCount) movies.")
                            self.tableView.reloadData()
                            self.isRefreshing = false
                        }
                    }
                }
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromSearch" {
            let viewController = segue.destination as? OneMovieViewController
            viewController?.oneMovie = moviesSearched[rowSelected]
        }
    }
    

}

extension  SearchMoviesViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieTableViewCell
            cell.setMovie(movie: moviesSearched[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "refreshCell", for: indexPath) as! RefreshTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return moviesSearched.count
        } else {
            return 1
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
        performSegue(withIdentifier: "fromSearch", sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSearchContentInput && isfirstSearchFound
        {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height

            if (offsetY > contentHeight - scrollView.frame.height) && (contentHeight - scrollView.frame.height) > 0 && !isRefreshing {
                print("offset \(offsetY)  contentHeight\(contentHeight) scrollView.frame.height \(scrollView.frame.height)")
                currentPage += 1
                loadMoreMovies(ofPage: currentPage)
            }
        }
    }
    
    
}

extension SearchMoviesViewController:UISearchBarDelegate{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
          searchBar.setShowsCancelButton(false, animated: true)
          searchBar.text = ""
          searchBar.endEditing(true)
      }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // hide cancel button in searchBar
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        if searchBar.text != nil {
            isSearchContentInput = true
            if isFirstTimeSearch {
                tableView.dataSource = self
                tableView.delegate = self
                self.tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "movieCell")
                self.tableView.register(UINib(nibName: "RefreshTableViewCell",bundle:nil), forCellReuseIdentifier: "refreshCell")
                isFirstTimeSearch = false
            }
            print("going to search \(searchBar.text!)")
            if moviesSearched.count != 0{
                isRefreshing = false
                self.currentPage = 1
                moviesSearched = []
                tableView.reloadData()
                print("Movies searched emptied for new data.")
            }
            let searchString = searchBar.text!
            let processedString = searchString.trimmingCharacters(in: .whitespaces)
            let urlString = getSearchMovieURL(query: processedString, page: currentPage)
            print(urlString)

            Alamofire.request(urlString).responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    //print(swiftyJsonVar)
                    self.moviesInfoSearched = DiscoverResult(page: swiftyJsonVar["page"].intValue, total_results: swiftyJsonVar["total_results"].intValue, total_pages: swiftyJsonVar["total_pages"].intValue)
                    let results = swiftyJsonVar["results"].arrayValue
                    if results.count == 0 {
                        self.currentCount = 0
                        self.isSearchContentInput = false
                        self.currentPage = 1
                        self.isfirstSearchFound = false
                        //print("\(self.currentCount)  \(self.isSearchContentInput)   \(self.currentPage)")
                        let alertController = UIAlertController(title: "No Movies Found", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:((UIAlertAction) -> Void)? { _ in
                            }))
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.isfirstSearchFound = true
                        print("Search and find \(results.count)  movies.")
                        for one in results {
                            let genre_idsArray = one["genre_ids"].arrayValue
                            var ids: [Int] = []
                            for oneID in genre_idsArray {
                                ids.append(oneID.intValue)
                            }
                            let oneMovie = Movie(popularity: one["popularity"].doubleValue, vote_count: one["vote_count"].intValue, video: one["video"].boolValue, poster_path: one["poster_path"].stringValue, id: one["id"].intValue, adult: one["adult"].boolValue, backdrop_path: one["backdrop_path"].stringValue, original_language: one["original_language"].stringValue, original_title: one["original_title"].stringValue, genre_ids: ids, title: one["title"].stringValue, vote_average: one["vote_average"].intValue, overview: one["overview"].stringValue, release_date: one["release_date"].stringValue)
                            self.moviesSearched.append(oneMovie)
                        }
                        //print("Movies Array\n\n\(self.moviesSearched)")
                        DispatchQueue.main.async {
                            self.currentCount = self.moviesSearched.count
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
}
