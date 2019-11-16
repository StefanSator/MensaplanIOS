//
//  PopularMealsViewController.swift
//  Mensaplan
//
//  Created by Stefan Sator on 16.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents

class PopularMealsViewController: UIViewController {
    @IBOutlet weak var trophyAnimationView: AnimationView!
    @IBOutlet weak var thumbsAnimationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trophyAnimationView.play()
        trophyAnimationView.loopMode = LottieLoopMode.loop
        
        thumbsAnimationView.play()
        thumbsAnimationView.loopMode = LottieLoopMode.loop
    }

}
