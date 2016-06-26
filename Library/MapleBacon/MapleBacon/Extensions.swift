//
//  Extensions.swift
//  MapleBacon
//
//  Created by Danilo Topalovic on 27.06.16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

internal extension CGSize {
    
    func scaled(factor: CGFloat? = nil) -> CGSize {
        let scale = factor ?? UIScreen.main().scale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
    
    func zeroBoundedRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
}

internal extension CGRect {
    
    func scaled(factor: CGFloat? = nil) -> CGRect {
        let scale = factor ?? UIScreen.main().scale
        return CGRect(x: self.origin.x * scale, y: self.origin.y * scale, width: self.size.width * scale, height: self.size.height * scale)
    }
    
    func zeroBoundedRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    }
}
