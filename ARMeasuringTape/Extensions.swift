//
//  Extensions.swift
//  ARMeasuringTape
//
//  Created by NguyenPham on 7/8/17.
//  Copyright © 2017 Softgaroo. All rights reserved.
//

import Foundation
import ARKit

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension SCNVector3 {
    func distance(_ receiver: SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(abs(sqrt(xd * xd + yd * yd + zd * zd)))

        return distance
    }
}

extension UIImage {
    func rotated90() -> UIImage? {
        let rotateSize = CGSize(width: self.size.height, height: self.size.width)
        UIGraphicsBeginImageContextWithOptions(rotateSize, true, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.rotate(by: CGFloat(Double.pi / 2))
            context.translateBy(x: size.width / 2, y: -size.height / 2)
            context.scaleBy(x: 1.0, y: -1.0)

            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            context.draw(cgImage!, in: drawRect)
            let newImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImg
        }
        return nil
    }
}
