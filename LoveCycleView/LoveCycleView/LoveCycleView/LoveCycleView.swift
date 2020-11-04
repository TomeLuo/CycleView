//
//  LovePageControl.swift
//  LoveCycleView
//
//  Created by 童川 on 2019/12/2.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import Kingfisher

@objc public protocol LoveCycleViewProtocol: class {
    /// 配置默认的cell,
    @objc optional func cycleViewConfigureDefaultCell(_ cycleView: LoveCycleView, imageView: UIImageView,titleLabel: UILabel,  index: Int)
    /// 自定义cell
    @objc optional func cycleViewCustomCellSetup(_ cycleView: LoveCycleView, cell: UICollectionViewCell, for index: Int)
    /// 滚动到第index个cell
    @objc optional func cycleViewDidScrollToIndex(_ cycleView: LoveCycleView, index: Int)
    /// 点击了第index个cell
    @objc optional func cycleViewDidSelectedIndex(_ cycleView: LoveCycleView, index: Int)
    /// pageControl设置
    @objc optional func cycleViewConfigurePageControl(_ cycleView: LoveCycleView, pageControl: LovePageControl)
    
}

public class LoveCycleView: UIView {
    /// 设置本地图片
    /// - Parameter namesGroup: image数组
    /// - Parameter titlesGroup: 标题数组
    public func setImagesGroup(_ namesGroup: Array<String?>,
                               titlesGroup: Array<String?>? = nil) {
        if namesGroup.count == 0 { return }
        realDataCount = namesGroup.count
        self.imageNamesGroup = namesGroup
        self.titlesGroup = titlesGroup ?? []
        self.imageUrlsGroup = []
        reload()
    }
    
    /// 设置网络图片
    /// - Parameter urlsGroup: url数组
    /// - Parameter titlesGroup: 标题数组
    public func setUrlsGroup(_ urlsGroup: Array<String?>,
                             titlesGroup: Array<String?>? = nil) {
        if urlsGroup.count == 0 { return }
        realDataCount = urlsGroup.count
        self.imageUrlsGroup = urlsGroup
        self.titlesGroup = titlesGroup ?? []
        self.imageNamesGroup = []
        reload()
    }
    
    /// 设置文字
    /// - Parameter titlesGroup: 文字数组
    public func setTitlesGroup(_ titlesGroup: Array<String?>) {
        if titlesGroup.count == 0 { return }
        realDataCount = titlesGroup.count
        self.isOnlyText = true
        self.imageNamesGroup = []
        self.imageUrlsGroup = []
        self.titlesGroup = titlesGroup
        reload()
    }
    
    /// 自定义cell  纯代码样式
    /// - Parameter identifier: 标志字符串
    /// - Parameter customClass: 类名
    /// - Parameter dataCount: 数据数目
    public func setCustomCellWithClass(identifier: String,customClass:AnyClass,dataCount: Int){
        reuseIdentifier = identifier
        collectionView.register(customClass.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.imageNamesGroup = []
        self.imageUrlsGroup = []
        self.titlesGroup = []
        realDataCount = dataCount
        reload()
    }
    
    /// 自定义cell  NIB样式
    /// - Parameter identifier: 标志字符串
    /// - Parameter customNib: 类名
    /// - Parameter dataCount: 数据数目
    public func setCustomCellWithNib(identifier: String,customNibName: String,dataCount: Int){
        reuseIdentifier = identifier
        collectionView.register(UINib(nibName:customNibName , bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.imageNamesGroup = []
        self.imageUrlsGroup = []
        self.titlesGroup = []
        realDataCount = dataCount
        reload()
    }
    
    /// cell identifier
    private var reuseIdentifier: String = "LoveCycleDefaultCell"
    /// 是否自动滚动，默认true
    public var isAutomatic: Bool = true
    /// 是否无限轮播，默认true
    public var isInfinite: Bool = true {
        didSet {
            if isInfinite == false {
                itemsCount = realDataCount <= 1 || !isInfinite ? realDataCount : realDataCount*200
                collectionView.reloadData()
                collectionView.setContentOffset(.zero, animated: false)
                dealFirstPage()
            }
        }
    }
    /// 滚动时间间隔，默认2s
    public var timeInterval: Int = 2
    /// 滚动方向，默认横向
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet { flowLayout.scrollDirection = scrollDirection }
    }
    /// 占位图
    public var placeholderImage: UIImage? = nil {
        didSet { placeholderImgView.image = placeholderImage }
    }
    /// item大小，默认LoveCycleView大小
    public var itemSize: CGSize? {
        didSet {
            guard let itemSize = itemSize else { return }
            let width = min(bounds.size.width, itemSize.width)
            let height = min(bounds.size.height, itemSize.height)
            flowLayout.itemSize = CGSize(width: width, height: height)
        }
    }
    /// 中间item的放大比例, >=1
    public var itemZoomScale: CGFloat = 1 {
        didSet {
            collectionView.isPagingEnabled = itemZoomScale == 1
            flowLayout.scale = itemZoomScale
        }
    }
    /// item 间距
    public var itemSpacing: CGFloat = 0 {
        didSet { flowLayout.minimumLineSpacing = itemSpacing }
    }
    
    /// delegate
    public weak var delegate: LoveCycleViewProtocol?
    
    ///是否是自定义cell，默认false
    public var isCustomCell: Bool = false
    //=============================================
    private var pageControl: LovePageControl!
    private var flowLayout: LoveCycleLayout!
    private var collectionView: UICollectionView!
    private var placeholderImgView: UIImageView!
    private var imageNamesGroup: Array<String?> = []
    private var imageUrlsGroup: Array<String?> = []
    private var titlesGroup: Array<String?> = []
    private var timer: Timer?
    private var itemsCount: Int = 0
    private var realDataCount: Int = 0
    private var isOnlyText:Bool = false
    
    override  init(frame: CGRect) {
        super.init(frame: frame)
        addPlaceholderImgView()
        addCollectionView()
        addPageControl()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addPlaceholderImgView()
        addCollectionView()
        addPageControl()
    }
    
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: frame.size.height-25, width: frame.size.width, height: 25)
        collectionView.setContentOffset(.zero, animated: false)
        dealFirstPage()
        delegate?.cycleViewConfigurePageControl?(self, pageControl: pageControl)
    }
}

// MARK: - setupUI
extension LoveCycleView {
    
    private func addPlaceholderImgView() {
        placeholderImgView = UIImageView(frame: CGRect.zero)
        placeholderImgView.image = placeholderImage
        addSubview(placeholderImgView)
        placeholderImgView.translatesAutoresizingMaskIntoConstraints = false
        let hCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|[placeholderImgView]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["placeholderImgView": placeholderImgView!])
        let vCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|[placeholderImgView]|",
                                                   options: NSLayoutConstraint.FormatOptions(),
                                                   metrics: nil,
                                                   views: ["placeholderImgView": placeholderImgView!])
        addConstraints(hCons)
        addConstraints(vCons)
    }
    
    private func addCollectionView() {
        flowLayout                                    = LoveCycleLayout()
        flowLayout.itemSize                           = itemSize != nil ? itemSize! : bounds.size
        flowLayout.minimumInteritemSpacing            = 10000
        flowLayout.minimumLineSpacing                 = itemSpacing
        flowLayout.scrollDirection                    = scrollDirection
        
        collectionView                                = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor                = UIColor.clear
        collectionView.bounces                        = false
        collectionView.showsVerticalScrollIndicator   = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate                       = self
        collectionView.dataSource                     = self
        collectionView.scrollsToTop                   = false
        collectionView.decelerationRate               = UIScrollView.DecelerationRate(rawValue: 0.0)
        registerCell()
        addSubview(collectionView)
    }
    
    /// add by LeeYZ
    private func registerCell() {
        collectionView.register(LoveCycleDefaultCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func addPageControl() {
        pageControl = LovePageControl()
        addSubview(pageControl)
    }
    
    private func reload() {
        placeholderImgView.isHidden = true
        itemsCount = realDataCount <= 1 || !isInfinite ? realDataCount : realDataCount*200
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        dealFirstPage()
        if isAutomatic { startTimer() }
        if pageControl.isHidden { return }
        pageControl.numberOfPages = realDataCount
        pageControl.isHidden = realDataCount == 1 || isOnlyText
        pageControl.currentPage = currentIndex() % realDataCount
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension LoveCycleView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cycleCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let index = indexPath.item % realDataCount
        
        ///自定义cell
        if isCustomCell , self.delegate?.cycleViewCustomCellSetup?(self, cell: cycleCell, for: index) != nil{
            return cycleCell
        }
        /// 使用默认的cell
        guard let cell = cycleCell as? LoveCycleDefaultCell else { return cycleCell }
        cell.onlyText = imageNamesGroup.count == 0 && imageUrlsGroup.count == 0
        let title = index < titlesGroup.count ? titlesGroup[index] : nil
        cell.titleLabel.text = title
        if imageNamesGroup.count != 0 {
            let imageName = index < imageNamesGroup.count ? imageNamesGroup[index] : nil
            cell.imageView.image = UIImage(named: imageName ?? "")
        }
        if imageUrlsGroup.count != 0 {
            let imageUrl = index < imageUrlsGroup.count ? imageUrlsGroup[index] : nil
            cell.imageView.kf.setImage(with: URL(string: imageUrl ?? ""), placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        delegate?.cycleViewConfigureDefaultCell?(self, imageView: cell.imageView, titleLabel: cell.titleLabel, index: index)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let centerViewPoint = convert(collectionView.center, to: collectionView)
        guard let centerIndex = collectionView.indexPathForItem(at: centerViewPoint) else { return }
        if indexPath.item == centerIndex.item {
            let index = indexPath.item % realDataCount
            if let delegate = delegate { delegate.cycleViewDidSelectedIndex?(self, index: index) }
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension LoveCycleView {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutomatic { cancelTimer() }
        dealLastPage()
        dealFirstPage()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutomatic { startTimer() }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let delegate = delegate else { return }
        let index = currentIndex() % realDataCount
        pageControl?.currentPage = index
        delegate.cycleViewDidScrollToIndex?(self, index: index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = currentIndex() % realDataCount
    }
}

// MARK: - 处理第一帧和最后一帧
extension LoveCycleView {
    private func dealFirstPage() {
        if currentIndex() == 0 && itemsCount > 1 && isInfinite {
            let targetIndex = itemsCount / 2
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
        }
    }
    private func dealLastPage() {
        if currentIndex() == itemsCount-1 && itemsCount > 1 && isInfinite {
            let targetIndex = itemsCount / 2 - 1
            let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
        }
    }
}

// MARK: - 定时器操作
extension LoveCycleView {
    private func startTimer() {
        if !isAutomatic { return }
        if itemsCount <= 1 { return }
        cancelTimer()
        timer = Timer.init(timeInterval: Double(timeInterval), target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    private func cancelTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func timeRepeat() {
        let current = currentIndex()
        var targetIndex = current + 1
        if (current == itemsCount - 1) {
            if isInfinite == false {return}
            dealLastPage()
            targetIndex = itemsCount / 2
        }
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: true)
    }
    
    private func currentIndex() -> Int {
        let itemWH = scrollDirection == .horizontal ? flowLayout.itemSize.width+itemSpacing : flowLayout.itemSize.height+itemSpacing
        let offsetXY = scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        if itemWH == 0 { return 0 }
        let index = round(offsetXY / itemWH)
        return Int(index)
    }
}

