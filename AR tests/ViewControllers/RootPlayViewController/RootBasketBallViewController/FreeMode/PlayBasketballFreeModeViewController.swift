//
//  PlayBasketballViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Each

class PlayBasketballFreeModeViewController: RootBasketBallViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        modeLabel.text = "Free Mode"
    }

    override func back() {
        customAlertView = BluredShadowView(title: "Are you sure to finish the game?", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
            self.getScoreView(game: GameToPresentOptions.basketballFree, score: self.score)
            transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
            self.backButton.isUserInteractionEnabled = false
        })
        view.addSubview(customAlertView!)
        customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
    }
}

