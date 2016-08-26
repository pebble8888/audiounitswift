//
//  ViewController.swift
//  audiounitswiftOSX
//
//  Created by pebble8888 on 2016/08/26.
//  Copyright © 2016年 pebble8888. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var myAudioPlayer:MyAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        myAudioPlayer = MyAudioPlayer()
        myAudioPlayer.play()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

