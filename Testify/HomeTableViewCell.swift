//
//  HomeTableViewCell.swift
//  Testify
//
//  Created by Pulkit Gambhir on 1/23/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Player

class HomeTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var userImg: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var thumbImg: UIImageView!
    
    @IBOutlet weak var vidBtn: UIButton!
    
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var likeCount: UIButton!
    
    @IBOutlet weak var cmntCount: UIButton!
    
    @IBOutlet weak var shareCount: UIButton!
    
    @IBOutlet weak var playView: UIView!
    
    var player: Player!
    
}

