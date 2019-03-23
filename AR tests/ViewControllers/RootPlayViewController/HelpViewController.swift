//
//  HelpViewController.swift
//  AR tests
//
//  Created by Yu Wang on 3/2/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

let helpCellID = "helper cell"

class HelpViewController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var backButton = CustomBackButton(image: #imageLiteral(resourceName: "goBack"))
    
    var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionview = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionview.register(HelperCell.self, forCellWithReuseIdentifier: helpCellID)
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        return collectionview
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpCollectionView()
        setUpBackButton()
    }
    
    func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
            ]
        )
    }
    
    func setUpBackButton(){
        view.addSubview(backButton)
        backButton.setConstraints()
        
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        transtitionWidgetButton(with: backButton, x: 100, y: 0, alpha: 1)
    }
    
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllItemsAndMissions.allHelpers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let helper = AllItemsAndMissions.allHelpers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: helpCellID, for: indexPath)
        if let cell = cell as? HelperCell{
            cell.title.text = helper.title
            cell.imageView.image = helper.snapShot
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let helper = AllItemsAndMissions.allHelpers[indexPath.row]
        let vc = HelperContentViewController(title: helper.title, texts: helper.texts, images: helper.images)
        present(vc, animated: true, completion: nil)
    }
}

class HelperCell:UICollectionViewCell{
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.font = getFont(withSize: 30)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = frame.width - 24
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.orange
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.3
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
            ]
        )
        
        addSubview(title)
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct Helper{
    var snapShot:UIImage
    var title:String
    var texts:[String]
    var images:[UIImage]
}

class HelperContentViewController:UIViewController{
    
    var backButton = CustomBackButton(image: #imageLiteral(resourceName: "goBack"))
    
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.frame = self.view.frame
        view.contentSize = CGSize(width: self.view.frame.width, height: 3000)
        view.backgroundColor = UIColor.white
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.font = getFont(withSize: 30)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = view.frame.width - 48
        label.textAlignment = .center
        label.textColor = UIColor.orange
        return label
    }()
    
    var texts = [String]()
    
    var textFields = [UILabel]()
    
    var images = [UIImage]()
    
    var imagesViews = [UIImageView]()
    
    init(title:String,texts:[String],images:[UIImage]){
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        self.texts = texts
        self.images = images
        calculateHeight()
        self.setUpContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateHeight(){
        var height:CGFloat = 0
        self.texts.forEach { (string) in
            height += estimateTrameForText(text: string, fontSize: 20).height
        }
        self.images.forEach { (image) in
            height += image.size.height/image.size.width*(view.frame.width-24)
        }
        self.scrollView.contentSize.height = height + estimateTrameForText(text: titleLabel.text!, fontSize: 20).height + 400
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
//        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//
//        }
        self.setUpContent()
        setUpBackButton()
    }
    
    func setUpBackButton(){
        scrollView.addSubview(backButton)
        backButton.setConstraints()
        
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        transtitionWidgetButton(with: backButton, x: 100, y: 0, alpha: 1)
    }
    
    func setUpContent(){
        
        scrollView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100),
            ]
        )
        
        let numberOfContents = images.count > texts.count ? texts.count : images.count
        for index in 0..<numberOfContents{
//            let labelHeight = estimateTrameForText(text: texts[index], fontSize:18)
            let textField = UILabel()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.numberOfLines = 0
            textField.text = texts[index]
            textField.sizeToFit()
            textField.isUserInteractionEnabled = false
            textField.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 20))
            textField.adjustsFontForContentSizeCategory = true
            textField.preferredMaxLayoutWidth = view.frame.width - 24
            textField.textAlignment = NSTextAlignment.natural
            textField.textColor = UIColor.black
            view.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
                textField.topAnchor.constraint(equalTo: index == 0 ? titleLabel.bottomAnchor : imagesViews[index - 1].bottomAnchor, constant: 24),
                ]
            )
            self.textFields.append(textField)
            
            let imageView = UIImageView()
            imageView.image = images[index]
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = UIColor.lightGray
            imageView.isUserInteractionEnabled = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
                imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
                imageView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 12),
                imageView.heightAnchor.constraint(equalToConstant:  images[index].size.height/images[index].size.width*(view.frame.width-24))
                ]
            )
            self.imagesViews.append(imageView)
        }
    }
    
    private func estimateTrameForText(text:String,fontSize:Int) -> CGRect{
        let size = CGSize(width: view.frame.width - 24, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFontMetrics.default.scaledFont(for:UIFont.systemFont(ofSize: CGFloat(fontSize)))], context: nil)
    }
    
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
}
