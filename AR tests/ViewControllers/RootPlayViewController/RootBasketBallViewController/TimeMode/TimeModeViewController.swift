//
//  TimeModeViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/20/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Each

class TimeModeViewController: RootBasketBallViewController {
    
    var countDownTimer = Each.init(1).seconds
    
    var maxGameTime = 120
    
    var timeLeft = 120{
        didSet{
            DispatchQueue.main.async{
                self.countDownLabel.text = "Time\n\(self.timeLeft)"
            }
        }
    }
    
    var countDownLabel = CustomRoundedRectLabel()

    override func viewDidLoad() {
        modeLabel.text = "Time Mode"
        super.viewDidLoad()
        setUpCountDownLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countDownTimer.stop()
    }
    
    func setUpCountDownLabel(){
        countDownLabel.text = "Time\n\(maxGameTime)"
        view.addSubview(countDownLabel)
        countDownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countDownLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:100).isActive = true
    }

    override func proceedGoal(with node: SCNNode) {
        super.proceedGoal(with: node)
        countDownTimer.perform { () -> NextStep in
            if self.timeLeft <= 0{
                self.sceneView.session.pause()
                self.getScoreView(game: GameToPresentOptions.basketballTimeLimited, score: self.score)
                transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                self.backButton.isUserInteractionEnabled = false
                return .stop
            }
            self.timeLeft -= 1
            return .continue
        }
    }
    
    
    override func back() {
        customAlertView = BluredShadowView(title: "Are you sure to finish the game?", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
            self.getScoreView(game: GameToPresentOptions.basketballTimeLimited, score: self.score)
            transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
            self.backButton.isUserInteractionEnabled = false
        })
        view.addSubview(customAlertView!)
        customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
        countDownTimer.stop()
    }
    
    deinit {
        countDownTimer.stop()
    }
}
