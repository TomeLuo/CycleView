//
//  LoveCycleDefaultCell.swift
//  LoveCycleView
//
//  Created by 童川 on 2019/12/3.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

class LoveCycleDefaultCell: UICollectionViewCell {
    
    var imageView  : UIImageView!
    var titleLabel : UILabel!
    var onlyText   : Bool = false {
        didSet {
            if onlyText {
                titleLabel.frame = contentView.bounds
            }else{
                titleLabel.frame = CGRect(x: 0, y: contentView.bounds.size.height-25, width: contentView.bounds.size.width, height: 25)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addImageView()
        addTitleLabel()
    }
    private func addImageView() {
           imageView = UIImageView(frame: contentView.bounds)
           imageView.clipsToBounds = true
           contentView.addSubview(imageView)
       }
       
       private func addTitleLabel() {
           titleLabel = UILabel()
           titleLabel.textColor = .gray
           titleLabel.font = UIFont.systemFont(ofSize: 15)
           titleLabel.clipsToBounds = true
           contentView.addSubview(titleLabel)
       }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
