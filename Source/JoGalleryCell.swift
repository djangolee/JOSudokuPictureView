//
//  JoGalleryCell.swift
//  JoGallery
//
//  Created by django on 5/17/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

open class JoGalleryCell: UICollectionViewCell {
    
    // MARK: Member variable
    
    open var minimumLineSpacing: CGFloat = 0
    
    public let containView = JoGallerCellContainView()
    public var containAnimateView: UIView {
        get {
            return containView.contentView
        }
    }
    
    fileprivate var layoutCenterX: NSLayoutConstraint?
    fileprivate var collectionView: UICollectionView? {
        willSet {
            removeObserver(collectionView)
            addObserver(newValue)
        }
    }
    
    // MARK: Life cycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(collectionView)
    }
    
    // MARK: Override
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        var next: UIResponder? = nil
        if let superview = superview, window != nil {
            next = superview
            while true {
                if next is UICollectionView {
                    break
                } else if next == nil {
                    break
                } else {
                    next = next?.next
                }
            }
            collectionView = next as? UICollectionView
        } else {
            collectionView = nil
        }
    }
    
    open func update(maxZoomScale: CGFloat, originSize: CGSize) {
        containView.update(maxZoomScale: maxZoomScale, originSize: originSize)
    }
}

// MARK: About Observer

extension JoGalleryCell {
    
    fileprivate func addObserver(_ scrollView: UIScrollView?) {
        scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
    }
    
    fileprivate func removeObserver(_ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scrollView = collectionView {
            scrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let centerX = layoutCenterX else { return }
        var rect = CGRect.zero
        rect.origin = scrollView.contentOffset
        rect.size = scrollView.frame.size
        
        guard frame.intersects(rect) else {
            if centerX.constant != 0 {
                centerX.constant = 0
            }
            return
        }
        
        if rect.minX == frame.minX {
            centerX.constant = 0
        } else {
            let offset = (frame.minX - rect.minX) / frame.width * (minimumLineSpacing / 2)
            if !offset.isNaN {
                centerX.constant = offset
            }
        }
    }
}

// MARK: Setup

extension JoGalleryCell {
    
    fileprivate func setup() {
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        
        setupContainView()
        bindingSubviewsLayout()

    }
    
    private func bindingSubviewsLayout() {
        containView.translatesAutoresizingMaskIntoConstraints = false
        layoutCenterX = NSLayoutConstraint(item: containView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        NSLayoutConstraint(item: containView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0).isActive = true
        layoutCenterX?.isActive = true
    }
    
    private func setupContainView() {
        contentView.addSubview(containView)
    }
}
