//
//  XMAnimatedLogoView.swift
//  XMiOS
//
//  Created by Karl Holmlöv on 2022-02-24.
//  Copyright © 2022 XMReality. All rights reserved.
//

import SwiftUI
import FLAnimatedImage

struct XMAnimatedLogoView: UIViewRepresentable {
    
    private let name: String
    @Binding var shouldAnimate: Bool
      
    init(name: String, shouldAnimate: Binding<Bool>) {
        self.name = name
        _shouldAnimate = shouldAnimate
    }
    
    func makeUIView(context: Context) -> XMGIFImageView {
        return XMGIFImageView(name: name)
    }
    
    func updateUIView(_ uiView: XMGIFImageView, context: Context) {
        uiView.updateGIF(shouldAnimate: shouldAnimate)
    }
}
