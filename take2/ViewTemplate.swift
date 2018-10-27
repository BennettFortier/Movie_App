//
//  ViewTemplate.swift
//  take2
//
//  Created by Rena fortier on 10/20/18.
//  Copyright © 2018 Ben Fortier. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Foundation

class ViewTemplate: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    var id: Int?
    var image: UIImage!
    var score: String?
    var release: String?
    var overview: String?
    var favButton: UIButton?
    var ref: DatabaseReference!
    var button: UIButton?
    var rate: UIButton?
    var rateFrame: CGRect?
    var prompt: UITextField?
    var trailer: String?
    var spinMe: UIActivityIndicatorView?
    var trailerView: UIWebView?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        spinMe = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.backgroundColor = UIColor.white
       let viewFrame = CGRect(x: 0, y: 65, width: view.frame.width, height: view.frame.height/2)
        let background = UIView(frame: viewFrame)
        background.backgroundColor = UIColor.gray;
        view.addSubview(background)
        
        if trailer != nil {
            let imageFrame = CGRect(x: 0, y: 65, width: view.frame.width, height: view.frame.height/2)

            let container: UIView = UIView(frame: imageFrame)
            container.backgroundColor = .clear
            
            let spinMe2 = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinMe! = spinMe2
            spinMe!.center = CGPoint(x: imageFrame.width/2, y: imageFrame.height/2)
            spinMe!.startAnimating()
            
            
            container.addSubview(spinMe!)
            self.view.addSubview(container)
            spinMe?.startAnimating()

            trailerView = UIWebView(frame: imageFrame)
            trailerView?.delegate = self
            trailerView?.allowsInlineMediaPlayback = true
            trailerView?.mediaPlaybackRequiresUserAction = false
            DispatchQueue.global(qos: .userInitiated).async {
                guard
                    let youtubeURL = URL(string: self.trailer!)
                    else { return }
                self.trailerView?.loadRequest( URLRequest(url: youtubeURL) )
            }
        

        }
        else{
            let imageFrame = CGRect(x: view.frame.width/5, y: 65, width: 3 * (view.frame.width/5), height: view.frame.height/2)

            let imageView = UIImageView(frame: imageFrame)
            imageView.image = image
            view.addSubview(imageView)
        }
       
        
        let overviewFrame = CGRect(x: 0, y: 67 + view.frame.height/2, width: view.frame.width, height: view.frame.height/9)
        let overviewLabel = UITextView(frame: overviewFrame)
        overviewLabel.isEditable = false
        overviewLabel.text = overview
        overviewLabel.textAlignment = .center;
        view.addSubview(overviewLabel)

        let scoreFrame = CGRect(x: 0, y: view.frame.height/2 + 4 * view.frame.height/18, width: view.frame.width, height: view.frame.height/18)
        let scoreLabel = UILabel(frame: scoreFrame)
        scoreLabel.text = score
        scoreLabel.textAlignment = .center;
        view.addSubview(scoreLabel)

        let releaseFrame = CGRect(x: 0, y: view.frame.height/2 + 3.5 * view.frame.height/18, width: view.frame.width, height: view.frame.height/18)
        let releaseLabel = UILabel(frame: releaseFrame)
        releaseLabel.text = release
        releaseLabel.textAlignment = .center;
        view.addSubview(releaseLabel)
        
        
        let buttonFrame = CGRect(x: view.frame.width/9, y: view.frame.height/2 + 6 * view.frame.height/18,width: view.frame.width/3, height: view.frame.height/18)
        button = UIButton(frame: buttonFrame)
        button?.setTitleColor(.blue, for: .normal)
        button?.layer.borderWidth = 1
        button?.layer.borderColor = UIColor.blue.cgColor
        
         rateFrame = CGRect(x: 5 * view.frame.width/9, y: view.frame.height/2 + 6 * view.frame.height/18,width: view.frame.width/3, height: view.frame.height/18)
        rate = UIButton(frame: rateFrame!)
        rate?.setTitleColor(.blue, for: .normal)
        rate?.layer.borderWidth = 1
        rate?.layer.borderColor = UIColor.blue.cgColor
        rate?.setTitle("Rate Movie", for: .normal)
        rate?.addTarget(self, action: #selector(rateMovie), for: .touchUpInside)

        isFavorited(movie: title!)
        if button?.currentTitle != "Added"{
            button?.setTitle("Add to favorites", for: .normal)
            button?.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        }
        view.addSubview(button!)
        view.addSubview(rate!)
    }
    
    @objc func addToFavorites(){
        
        ref.child("Movie").child(title!).setValue([title!])
        button?.setTitle("Added", for: .normal)
        button?.removeTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
    }
    
    @objc func rateMovie(){
        promptUser()
    }
    func promptUser(){
        let pFrame = CGRect(x: 5 * view.frame.width/9, y: view.frame.height/2 + 6 * view.frame.height/18,width: view.frame.width/3, height: view.frame.height/18)
        prompt = UITextField(frame: pFrame)
        prompt!.layer.borderWidth = 1
        prompt!.layer.borderColor = UIColor.blue.cgColor
        prompt!.placeholder = "Enter 1 - 10"
        prompt!.textAlignment = .center
        prompt!.font = UIFont.boldSystemFont(ofSize: 16)
        rate?.removeFromSuperview()
        view.addSubview(prompt!)
        view.reloadInputViews()
        prompt!.delegate = self
    }
    func animateBack(){
        prompt!.removeFromSuperview()
        rate?.removeFromSuperview()
        button?.frame = CGRect(x: view.frame.width/3, y: view.frame.height/2 + 6 * view.frame.height/18,width: view.frame.width/3, height: view.frame.height/18)
        view.reloadInputViews()
    }
    
    func failedRate(){
        let alert = UIAlertController(title: "Error", message: "There has been an error rating this movie, please try again later. Sorry!", preferredStyle: .alert)
        self.present(alert, animated: true)
        animateBack()
    }
    func ratePost(ratingVal: Int){
        var val = ratingVal
        if val == 0 {
            val = 1
        }
        if val > 10 {
            val = 10
        }
       
        let headers = ["content-type": "application/json;charset=utf-8"]
        let parameters = ["value": ratingVal]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters)
        do{
            var urlString = "https://api.themoviedb.org/3/movie/"+String(id!)+"/rating?api_key=95d1c7575f05b60a7dd4694457223ae0"
            var url = URL(string: urlString)
            var request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    
                    print(error)

                } else {
                    let httpResponse = response as? HTTPURLResponse
//                    print("Success")

                }
            })
            
            dataTask.resume()
        }
        catch{
            self.failedRate()
        }
        self.animateBack()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
   
    
    func isFavorited(movie: String){
        var alreadyFavorited: Bool = false
        ref.observe(.value, with: {
            snapshot in
            let someData = snapshot.value as? NSDictionary
            if someData?["Movie"] != nil {
                let mov = someData!["Movie"] as? NSDictionary
                let keys = mov?.allKeys
                if keys != nil {
                    for key in keys! {
                        let temp = mov![key] as! NSArray
                        let name = "\(temp[0])"
                        if temp != nil{
                            if movie == name {
                                self.button?.setTitle("Added", for: .normal)
                            }
                           
                        }
                    }
                }
                
                
            }
        })

    }

  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            
            if text.isNumeric {
                var val = text
                ratePost(ratingVal: Int(val)!)
            }
            else{
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
                
                textField.layer.add(animation, forKey: "position")
                textField.text = ""
                textField.placeholder = "Enter Number"
            }
        }
        textField.resignFirstResponder()
        return false
    }


}
extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
extension ViewTemplate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinMe?.stopAnimating()
        self.view.addSubview(trailerView!)
    }
}
