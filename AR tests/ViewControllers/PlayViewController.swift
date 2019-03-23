//
//  PlayViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    var playButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Basketball", for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.65179127, blue: 0.2760472458, alpha: 1)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    var playButton2:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pool", for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.65179127, blue: 0.2760472458, alpha: 1)
        button.addTarget(self, action: #selector(pool), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpAndAddPlayButton()
        setUpAndAddPlayButton2()
    }
    
    func setUpAndAddPlayButton(){
        view.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setUpAndAddPlayButton2(){
        view.addSubview(playButton2)
        playButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton2.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton2.widthAnchor.constraint(equalToConstant: 300).isActive = true
        playButton2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
    }
    
    @objc func play(){
        present(PlayBasketballFreeModeViewController(), animated: true, completion: nil)
    }
    
    @objc func pool(){
        present(PlayPoolViewController(), animated: true, completion: nil)
    }
    
}
