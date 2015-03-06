//
//  ViewController.swift
//  SwiftPeople
//
//  Created by Dalton Cherry on 3/6/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit
import Skeets

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var users: Array<User>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch the users!
        User.getUsers{ (users: Array<User>) in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    //number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let users = self.users {
            return users.count
        }
        return 0
    }
    
    //style the cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UserTableViewCell! = tableView.dequeueReusableCellWithIdentifier("user") as? UserTableViewCell
        if cell == nil {
            cell = UserTableViewCell(style: .Default, reuseIdentifier: "user")
        }
        if let users = self.users {
            if indexPath.row < users.count {
                let user = users[indexPath.row]
                cell.imgView.image = nil
                cell.txtLabel.text = user.displayName
                if cell.currentImgUrl != "" {
                    ImageManager.cancel(cell.currentImgUrl)
                }
                ImageManager.fetch(user.picture.medium, progress: { (progress: Double) in
                    }, success: { (data: NSData) in
                        cell.imgView.image = UIImage(data: data)
                        cell.currentImgUrl = ""
                    }, failure: { (error: NSError) in
                        println("failed to get image: \(error)")
                })
                cell.currentImgUrl = user.picture.medium
            }
        }
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

