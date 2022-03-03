//
//  XMGIFImage.swift
//  XMiOS
//
//  Created by Karl Holmlöv on 2022-03-02.
//  Copyright © 2022 XMReality. All rights reserved.
//
import UIKit

class XMGIFImage: UIImage {
    
    private var gifData: Data?
    private var gifSource: CGImageSource?
    
    convenience init?(name: String) {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        
        else { return nil }
        
        self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        
        gifData = data
        gifSource = source
    }
    
    func staticImage() -> UIImage? {
        guard let data = gifData,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func animated() -> UIImage? {

        guard let gifData = gifData, let source = CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).map {
            // store in ms and truncate to compute GCD more easily
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        
        var frames = [UIImage]()
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                let frameCount = delays[i] / gcd
                
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            } else {
                return nil
            }
        }
        
        return UIImage.animatedImage(with: frames,
                                     duration: Double(duration) / 1000.0)
    }
    
    private func gcd(_ a: Int, _ b: Int) -> Int {
        let absB = abs(b)
        let r = abs(a) % absB
        if r != 0 {
            return gcd(absB, r)
        } else {
            return absB
        }
    }

    private func delayForImage(at index: Int, source: CGImageSource) -> Double {
        let defaultDelay = 1.0
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return defaultDelay
        }
        let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                         to: AnyObject.self)
        if delayWrapper.doubleValue == 0 {
            delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                         to: AnyObject.self)
        }
        
        if let delay = delayWrapper as? Double,
           delay > 0 {
            return delay
        } else {
            return defaultDelay
        }
    }

}


