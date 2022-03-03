//
//  XMGIFImageView.swift
//  XMiOS
//
//  Created by Karl Holmlöv on 2022-03-02.
//  Copyright © 2022 XMReality. All rights reserved.
//

import UIKit

class XMGIFImageView: UIView {

    enum AnimationState {
        case animate
        case paused
    }

    private let imageView = UIImageView()
    private var name: String?
    private var gif: XMGIFImage?
    private var lastAnimationState: AnimationState = .paused
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
        imageView.contentMode = .scaleAspectFit
        gif = XMGIFImage(name: name)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    /// Updates image view's image according to updated parameters
    /// - Parameter shouldAnimate: Should gif animate or display static image
    /// - Parameter finishAnimation: Should gif finish animation
    /// - Parameter pause: Should gif animation pause where it is at  // TODO not finished
    func updateGIF(shouldAnimate: Bool, finishAnimation: Bool = true, pause: Bool = false) {
        
        if shouldAnimate, let gif = gif, let animatedGIF = gif.animated(){
            imageView.image = animatedGIF
        } else if !shouldAnimate, let gif = gif, let staticImage = gif.staticImage() {
            imageView.image = staticImage
        }
    }
}
