//
//  ScoreView.swift
//  AR tests
//
//  Created by Yu Wang on 2/17/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import UIKit

class ScoreView:UIView{
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var okAction = {
        return
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = UIColor.green
        //        isUserInteractionEnabled = false
        addShadow(color: UIColor.black)
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        self.backgroundColor = UIColor.clear
        blurView.isUserInteractionEnabled = false
    }
    
    convenience init(score:Int?,timeOfPlay:Int,highScore:Int,okAction:@escaping ()->Void,friendsScore:Int? = nil){
        self.init()
        var highScoreLabel: UILabel?
        if let score = score{
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Your Score: "
            label.font = getFont(withSize: 28, adjustSizeAccordingToSystem: false)
            label.adjustsFontForContentSizeCategory = true
            addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                ]
            )
            
            let scoreLabel = UILabel()
            scoreLabel.translatesAutoresizingMaskIntoConstraints = false
            scoreLabel.text = String(score)
            scoreLabel.font = getFont(withSize: 24, adjustSizeAccordingToSystem: false)
            scoreLabel.textColor = UIColor.red
            scoreLabel.adjustsFontForContentSizeCategory = true
            addSubview(scoreLabel)
            NSLayoutConstraint.activate([
                scoreLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
                scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                ]
            )
            
            var winLabel:UILabel?
            
            if let friendsScore = friendsScore{
                let friendsLabel = UILabel()
                friendsLabel.translatesAutoresizingMaskIntoConstraints = false
                friendsLabel.text = "Your Friend's Score:"
                friendsLabel.font = getFont(withSize: 28, adjustSizeAccordingToSystem: false)
                friendsLabel.adjustsFontForContentSizeCategory = true
                addSubview(friendsLabel)
                NSLayoutConstraint.activate([
                    friendsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 24),
                    friendsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                    ]
                )
                
                let friendsScoreLabel = UILabel()
                friendsScoreLabel.translatesAutoresizingMaskIntoConstraints = false
                friendsScoreLabel.text = String(friendsScore)
                friendsScoreLabel.textColor = UIColor.red
                friendsScoreLabel.font = getFont(withSize: 24, adjustSizeAccordingToSystem: false)
                friendsScoreLabel.adjustsFontForContentSizeCategory = true
                addSubview(friendsScoreLabel)
                NSLayoutConstraint.activate([
                    friendsScoreLabel.topAnchor.constraint(equalTo: friendsLabel.bottomAnchor, constant: 12),
                    friendsScoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                    ]
                )
                
                winLabel = UILabel()
                winLabel!.translatesAutoresizingMaskIntoConstraints = false
                if friendsScore > score{
                    winLabel!.text = "You Lose"
                }else if friendsScore < score{
                    winLabel!.text = "You Win"
                }else{
                    winLabel!.text = "Draw"
                }
                winLabel!.textColor = #colorLiteral(red: 1, green: 0.6645951271, blue: 0.2553175688, alpha: 1)
                winLabel!.font = getFont(withSize: 30, adjustSizeAccordingToSystem: false)
                winLabel!.adjustsFontForContentSizeCategory = true
                addSubview(winLabel!)
                NSLayoutConstraint.activate([
                    winLabel!.topAnchor.constraint(equalTo: friendsScoreLabel.bottomAnchor, constant: 12),
                    winLabel!.centerXAnchor.constraint(equalTo: centerXAnchor),
                    ]
                )
            }
            
            highScoreLabel = UILabel()
            highScoreLabel!.translatesAutoresizingMaskIntoConstraints = false
            highScoreLabel!.text = "Your High Score: \(highScore)"
            highScoreLabel!.font = getFont(withSize: 24, adjustSizeAccordingToSystem: false)
            highScoreLabel!.adjustsFontForContentSizeCategory = true
            addSubview(highScoreLabel!)
            
            if let winLabel = winLabel{
                NSLayoutConstraint.activate([
                    highScoreLabel!.topAnchor.constraint(equalTo: winLabel.bottomAnchor, constant: 12),
                    highScoreLabel!.centerXAnchor.constraint(equalTo: centerXAnchor),
                    ]
                )
            }else{
                NSLayoutConstraint.activate([
                    highScoreLabel!.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 12),
                    highScoreLabel!.centerXAnchor.constraint(equalTo: centerXAnchor),
                    ]
                )
            }
        }
        
        
        let levelUp = UILabel()
        levelUp.translatesAutoresizingMaskIntoConstraints = false
        levelUp.numberOfLines = 0
        levelUp.text = "Level Up !"
        levelUp.sizeToFit()
        levelUp.font = getFont(withSize: 30, adjustSizeAccordingToSystem: false)
        levelUp.adjustsFontForContentSizeCategory = true
        levelUp.preferredMaxLayoutWidth = 276
        levelUp.textAlignment = .center
        levelUp.textColor = UIColor.orange
        addSubview(levelUp)
        NSLayoutConstraint.activate([
            levelUp.centerYAnchor.constraint(equalTo: centerYAnchor),
            levelUp.centerXAnchor.constraint(equalTo: centerXAnchor),
            ]
        )
        levelUp.alpha = 0
        
        
        let vc = UIApplication.shared.keyWindow?.rootViewController as? MenuViewController
        let gameController = vc?.gameController
        let startNumber = gameController?.experience
        var destinationNumber = 0
        if let score = score{
             destinationNumber = startNumber! + (friendsScore != nil ? score*2 : score) + timeOfPlay
        }else{
            destinationNumber = startNumber! + timeOfPlay
        }
        gameController?.experience = destinationNumber
        
        
        let experienceLabel = UILabel()
        experienceLabel.translatesAutoresizingMaskIntoConstraints = false
        experienceLabel.numberOfLines = 1
        experienceLabel.text = "Experience: \(startNumber!)/\(Constants.experienceForLevel[gameController!.level]!)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            UIView.animate(withDuration: 0.5, animations: {
                experienceLabel.alpha = 0
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    experienceLabel.text = "Experience: \(destinationNumber)/\(Constants.experienceForLevel[gameController!.level]!)"
                    experienceLabel.alpha = 1
                    
                    while destinationNumber >= Constants.experienceForLevel[gameController!.level]!{
                        UIView.animate(withDuration: 1, animations: {
                            levelUp.alpha = 1
                            destinationNumber -= Constants.experienceForLevel[gameController!.level]!
                            gameController?.level += 1
                            gameController?.experience = destinationNumber
                            experienceLabel.text = "Experience: \(destinationNumber)/\(Constants.experienceForLevel[gameController!.level]!)"
                        }, completion: { (_) in
                            UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                levelUp.alpha = 0
                            }, completion: nil)
                        })
                    }
                    
                })
            })
        }
        
        experienceLabel.sizeToFit()
        experienceLabel.font = getFont(withSize: 22, adjustSizeAccordingToSystem: false)
        experienceLabel.adjustsFontForContentSizeCategory = true
        experienceLabel.textAlignment = .center
        experienceLabel.textColor = UIColor.yellow
        addSubview(experienceLabel)
        NSLayoutConstraint.activate([
            experienceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            ]
        )
        if let highScoreLabel = highScoreLabel{
            experienceLabel.topAnchor.constraint(equalTo: highScoreLabel.bottomAnchor, constant: 12).isActive = true
        }else{
             experienceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        }
        
        

        
        let randomNumber = friendsScore != nil ? Int.random(in: 1...2) : Int.random(in: 1...10)
        if randomNumber == 1{
            let getGemLabel = UILabel()
            getGemLabel.translatesAutoresizingMaskIntoConstraints = false
            getGemLabel.numberOfLines = 0
            getGemLabel.text = "You Have Found A Gem During The Game Play!"
            getGemLabel.sizeToFit()
            getGemLabel.font = getFont(withSize: 24, adjustSizeAccordingToSystem: false)
            getGemLabel.adjustsFontForContentSizeCategory = true
            getGemLabel.preferredMaxLayoutWidth = 276
            getGemLabel.textAlignment = .center
            getGemLabel.textColor = UIColor.yellow
            addSubview(getGemLabel)
            NSLayoutConstraint.activate([
                getGemLabel.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 12),
                getGemLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                ]
            )
            gameController?.gems += 1
            gameController?.rawGems += 1
        }
 
        self.okAction = okAction
        
        let okButton = BluredShadowView(title: "OK")
        addSubview(okButton)
        NSLayoutConstraint.activate([
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            okButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            okButton.heightAnchor.constraint(equalToConstant: 50),
            okButton.widthAnchor.constraint(equalToConstant: 80)
            ]
        )
        okButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ok)))
        
        
    }

    
    @objc func ok(){
        okAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
