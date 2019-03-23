//
//  BasketBallBallModeViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/23/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit

class BasketBallBallModeViewController: RootBasketBallViewController {

    let maximumBall = 12
    
    var ballThrown = 0{
        didSet{
            countDownLabel.text = "Balls\n\(maximumBall - ballThrown)"
            if ballThrown >= maximumBall{
                self.sceneView.isUserInteractionEnabled = false
                self.backButton.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getScoreView(game: GameToPresentOptions.basketballBallLimited, score: self.score)
                    transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                }
            }
        }
    }
    
    var countDownLabel = CustomRoundedRectLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCountDownLabel()
        modeLabel.text = "Ball Mode"
    }
    
    override func shootBall() {
        if ballThrown <= maximumBall{
            super.shootBall()
            ballThrown += 1
        }
    }
    
    func setUpCountDownLabel(){
        countDownLabel.text = "Balls\n\(maximumBall - ballThrown)"
        view.addSubview(countDownLabel)
        countDownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countDownLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:100).isActive = true
    }
    
    override func back() {
        customAlertView = BluredShadowView(title: "Are you sure to finish the game?", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
            self.getScoreView(game: GameToPresentOptions.basketballBallLimited, score: self.score)
            transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
            self.backButton.isUserInteractionEnabled = false
            self.sceneView.isUserInteractionEnabled = false
        })
        view.addSubview(customAlertView!)
        customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
    }

}

