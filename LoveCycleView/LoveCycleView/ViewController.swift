//
//  ViewController.swift
//  LoveCycleView
//
//  Created by 童川 on 2019/12/2.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

let width = UIScreen.main.bounds.size.width
let height = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    
    private var scrollView : UIScrollView!
    private var cycleView1 : LoveCycleView!
    private var cycleView2 : LoveCycleView!
    private var cycleView3 : LoveCycleView!
    private var cycleView4 : LoveCycleView!
    private var cycleView5 : LoveCycleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ///图片URL数组
        let imgUrlArray = ["http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171101181927887.jpg",
                           "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171114171645011.jpg",
                           "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171114172009707.png"]
        ///本地图片
        let imgNamesArray : [String?] = [ "h1","h2","h3"]
        ///文本数组
        let titleArray = ["图片一","图片二","图片三","图片四"]
        ///默认cell
        ///样式一： 图片上下滚动
        cycleView1.setUrlsGroup(imgUrlArray)
        cycleView1.delegate = self
        cycleView1.timeInterval = 3
        cycleView1.scrollDirection = .vertical
        ///样式二：图片左右滚动，居中放大
//        cycleView2.isAutomatic = false
//        cycleView2.isInfinite = false
        cycleView2.setImagesGroup(imgNamesArray, titlesGroup: titleArray)
        cycleView2.itemSize = CGSize(width: width - 160, height: (width - 160) * 150/375)
        cycleView2.itemZoomScale = 1.2
        cycleView2.itemSpacing = 40
        cycleView2.delegate = self
        cycleView2.isAutomatic = false
//        cycleView2.pageControl.isHidden = true
        ///样式三：常规样式
        cycleView3.setImagesGroup(imgNamesArray, titlesGroup: titleArray)
        cycleView3.itemSize = CGSize(width: width , height: (width) * 150/375)
        cycleView3.itemZoomScale = 1
        cycleView3.itemSpacing = 0
        cycleView3.delegate = self
        cycleView3.isInfinite = true
        ///样式四：单文本滚动
        cycleView4.setTitlesGroup(titleArray)
        cycleView4.scrollDirection = .vertical
        ///样式五：自定义cell
        cycleView5.setCustomCellWithNib(identifier: "CustomViewCell", customNibName:"CustomViewCell", dataCount: 5)
//        cycleView5.setCustomCellWithClass(identifier: "CustomViewCell", customClass: CustomViewCell, dataCount: 5)
        cycleView5.delegate = self
        cycleView5.isCustomCell = true
    }
    
    override func viewDidLayoutSubviews() {
        
        let conetntHeight = cycleView5.y + cycleView5.height + 30 + view.safeInsets.top + view.safeInsets.bottom
        if conetntHeight > height {
            scrollView.contentSize = CGSize(width: width, height: conetntHeight)
        }
    }
}
extension ViewController: LoveCycleViewProtocol {
    
    //默认样式
    func cycleViewConfigureDefaultCell(_ cycleView: LoveCycleView, imageView: UIImageView, titleLabel: UILabel, index: Int) {
        if cycleView == cycleView2 || cycleView == cycleView3 {
            titleLabel.textColor = UIColor.white
        }
    }
    ///自定义的样式cell
    func cycleViewCustomCellSetup(_ cycleView: LoveCycleView, cell: UICollectionViewCell, for index: Int) {
        if cycleView == cycleView5 {
            ///自定义cell的赋值
            let customCell = cell as! CustomViewCell
            customCell.titleLabel.text = "index ++++\(index)"
        }
    }
    ///点击回调
    func cycleViewDidSelectedIndex(_ cycleView: LoveCycleView, index: Int) {
        print("选中下标 ------\(index)")
    }
    
    //修改PageControl样式
    func cycleViewConfigurePageControl(_ cycleView: LoveCycleView, pageControl: LovePageControl) {
        if cycleView1 == cycleView {
            
            pageControl.pageIndicatorTintColor = UIColor.green
            pageControl.currentPageIndicatorTintColor = UIColor.red
        }
    }
}

// MARK : - UI
extension ViewController {
    
    private func setupUI() {
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor.white
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.bottom.right.equalTo(view)
        }
        //
        cycleView1 = LoveCycleView()
        cycleView1.backgroundColor = UIColor.lightGray
        contentView.addSubview(cycleView1)
        cycleView1.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeInsets.top)
            make.height.equalTo(80)
        }
        
        cycleView2 = LoveCycleView()
        cycleView2.backgroundColor = UIColor.lightGray
        contentView.addSubview(cycleView2)
        cycleView2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(cycleView1.snp.bottom).offset(15)
            make.height.equalTo(180)
        }
        
        cycleView3 = LoveCycleView()
        cycleView3.backgroundColor = UIColor.lightGray
        contentView.addSubview(cycleView3)
        cycleView3.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(cycleView2.snp.bottom).offset(15)
            make.height.equalTo(200)
        }
        
        cycleView4 = LoveCycleView()
        cycleView4.backgroundColor = UIColor.lightGray
        contentView.addSubview(cycleView4)
        cycleView4.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(cycleView3.snp.bottom).offset(15)
            make.height.equalTo(50)
        }
        
        cycleView5 = LoveCycleView()
        cycleView5.backgroundColor = UIColor.lightGray
        contentView.addSubview(cycleView5)
        cycleView5.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(cycleView4.snp.bottom).offset(15)
            make.height.equalTo(205)
        }
    }
}
