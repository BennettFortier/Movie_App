//
//  MovieController.swift
//  take2
//
//  Created by Rena fortier on 10/20/18.
//  Copyright © 2018 Ben Fortier. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct APIResults:Decodable {
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [Movie] = []
}
struct Movie: Decodable {
    var id: Int!
    var poster_path: String?
    var title: String
    var release_date: String
    var vote_average: Double
    var overview: String
    var vote_count:Int!
    var adult: Bool?
}
struct movieTrailers: Decodable{
    var id: Int!
    var results: [trailerResult] = []
}
struct trailerResult: Decodable{
    var key: String?
    var name: String?
    var site: String?
    var type: String?
}
class MovieController: UICollectionViewController, UITextFieldDelegate {
    var imageCache: [UIImage] = []
    var movieArray: [Movie] = []
    var trailerDictionary: [Int: String] = [:]
    fileprivate let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    fileprivate let itemsPerRow: CGFloat = 3
 
    fileprivate let reuseIdentifier = "movieCell"
    fileprivate let basePath = "http://image.tmdb.org/t/p/w185"
    fileprivate let base: String = "https://api.themoviedb.org/3/search/movie?api_key=95d1c7575f05b60a7dd4694457223ae0&query="
    fileprivate var adultString: String = "&include_adult=false"
    fileprivate var curQuery: String?
    @IBOutlet var collectionViewed: UICollectionView!
    
    @IBOutlet weak var spinMe: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Deals with data:
    func prepareRequest(){
        if let text = curQuery {
            if text != nil && text != "" && text != " " {
                spinMe.startAnimating()

                DispatchQueue.global(qos: .userInitiated).async {
                    let newString = text.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                    self.fetchData(query: newString)
                    self.getTrailers()
                    self.cacheImages()

                    
                    DispatchQueue.main.async {
                        self.collectionViewed.reloadData()
                        self.spinMe.stopAnimating()
                    }
                    
                }
                
            }
            else{
                self.movieArray = []
                self.collectionViewed.reloadData()
            }
        }
    }
    func fetchData(query: String){
        movieArray = []
        if movieArray.count == 0 {
            let urlSt = base + "" + query + "" + adultString
            let url = URL(string: urlSt)
            if url != nil {
                let data = try? Data(contentsOf: url!)
                let decoder = JSONDecoder()
                do{
                    if data != nil {
                        let resultsT:APIResults = try decoder.decode(APIResults.self, from: data!)
                        for mov in resultsT.results{
                            movieArray.append(mov)
                        }
                    }
                }
                catch let err{
                    print(err)
                }
            }
            else {
                print ( "nil")
            }
        }
    }
    func getTrailers(){
        for mov in movieArray{
            let id = mov.id
            let urlSt = "https://api.themoviedb.org/3/movie/" + String(id!) + "/videos?api_key=95d1c7575f05b60a7dd4694457223ae0&language=en-US"
            let url = URL(string: urlSt)
            if url != nil {
                let data = try? Data(contentsOf: url!)
                let decoder = JSONDecoder()
                do{
                    if data != nil {
                        let resultsT:movieTrailers = try decoder.decode(movieTrailers.self, from: data!)
                        for mov in resultsT.results{
                            if mov.site == "YouTube" && mov.type == "Trailer" {
                                if mov.key != nil && id != nil{
                                    trailerDictionary[id!] = "https://www.youtube.com/embed/" + mov.key!
                                }
                            }
                        }
                    }
                }
                catch let err{
                    print(err)
                }
            }
            else {
                print ( "nil")
            }
        }
        
    }

    func cacheImages(){
        imageCache = []
        var extend = ""
        for item in movieArray {
            if item.poster_path != nil {
                extend = item.poster_path!
                let path = basePath + "" + extend
                let url = URL(string: path)
                let data = try? Data(contentsOf: url!)
                if data != nil {
                    let image = UIImage(data: data!)
                    imageCache.append(image!)
                }
                
                
            }
            else{
                let temp = UIImage(named: "take2.jpeg")
                imageCache.append(temp!)
            }
        }

    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        curQuery = textField.text
        prepareRequest()

        textField.resignFirstResponder()
        return false
    }

    //Deals with my collectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        var numb = 20
        if movieArray.count < 20  {
            numb = movieArray.count
        }
        if imageCache.count < movieArray.count {
            numb = imageCache.count
        }

        return numb
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! customCell
        let text = movieArray[indexPath.row].title
        cell.label.text = text
   

        cell.image.image = imageCache[indexPath.row]
        cell.bringSubview(toFront: cell.label)
        cell.sendSubview(toBack: cell.image)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headMe", for: indexPath) as! Header
        headerView.searchBar.delegate = self;
        headerView.theSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        headerView.theSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        
      
       
            return headerView
      
    }
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        if value {
            adultString = "&include_adult=true"
        }
        else{
            adultString = "&include_adult=false"

        }
        prepareRequest()
        
    }
   override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movieArray[indexPath.row]
        let image2:UIImage = imageCache[indexPath.row]
        let title = movie.title
        let release = movie.release_date
        let overview = movie.overview
        let den: Double = Double(movie.vote_count * 10)
        let num = movie.vote_average * Double(movie.vote_count)
    var scoreString = ""
    if !den.isNaN && !num.isNaN{
        let score = ((num/den) * 100)
        if !score.isNaN {
            scoreString = String(Int(score))  + "/100"
        }
        else{
            scoreString = "No score recorded"
        }
    }
    else{
        scoreString = "No score recorded"
    }
    
        let newController = ViewTemplate()
        newController.score = scoreString
        newController.image = image2
        newController.overview = overview
        newController.release = release
        newController.title = title
        newController.id = movie.id
    if trailerDictionary[movie.id] != nil{
        newController.trailer = trailerDictionary[movie.id]!
    }
        navigationController?.pushViewController(newController, animated: true)
   }

 
}
extension MovieController : UICollectionViewDelegateFlowLayout {
 
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        paddingSpace -= 5
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let availableHeight = view.frame.height - paddingSpace
        let heightPerItem = availableHeight/itemsPerRow
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

