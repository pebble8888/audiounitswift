//
//  ViewController.swift
//  audiounitswift
//
//  Created by pebble8888 on 2015/11/30.
//  Copyright © 2015年 pebble8888. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var myAudioPlayer:MyAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        myAudioPlayer = MyAudioPlayer()
        myAudioPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

