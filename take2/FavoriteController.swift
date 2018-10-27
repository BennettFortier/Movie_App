//
//  FavoriteController.swift
//  take2
//
//  Created by Rena fortier on 10/21/18.
//  Copyright © 2018 Ben Fortier. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavoriteController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var favorites: [String] = []
    var removable: [Any] = []
    var ref: DatabaseReference!

    func getFavorites(){
        ref = Database.database().reference()
        ref.observe(.value, with: {
            snapshot in
            self.favorites.removeAll()
            let someData = snapshot.value as? NSDictionary
            self.removable.append(someData)
            if someData?["Movie"] != nil {
                let mov = someData!["Movie"] as? NSDictionary
                let keys = mov?.allKeys
                if keys != nil {
                    for key in keys! {
                        let temp = mov![key] as! NSArray
                        let name = temp[0]
                        print(name)
                        if temp != nil{
                            self.favorites.append("\(name)")
                        }
                    }
                }
               
                
            }
            self.tableView.reloadData()
        })

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print(favorites[indexPath.row])
            ref.child("Movie").child(favorites[indexPath.row]).setValue([nil]) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Data saved successfully!")
                }
            }
            self.getFavorites()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        myCell.textLabel?.text = favorites[indexPath.row]
        return myCell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getFavorites()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
