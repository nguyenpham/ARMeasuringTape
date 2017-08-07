//
//  RulerNode.swift
//  ARMeasuringTape
//
//  Created by NguyenPham on 7/8/17.
//  Copyright © 2017 Softgaroo. All rights reserved.
//

import Foundation
import ARKit

/*
 * Known problem: The image for the measure should not longer than 16384 pixels (limit of MTLTextureDescriptor)
 * Thus we limit the measure about 1.5m (MaxMeasureLength = 1.5)
 */
class RulerNode : SCNNode {
    /*
     * Constants for drawing measure
     * If you want to change the appearance of the measure, change those constants
     */
    fileprivate let MaxMeasureLength: Float = 0.3

    fileprivate let pixelPerMilimeter: CGFloat = 3
    fileprivate let heightInMilimeter: CGFloat = 20

    fileprivate let tapeBackgroundColor = UIColor.yellow

    // Number
    fileprivate let font = UIFont(name: "Helvetica", size: 18)!
    fileprivate let textColor = UIColor.black
    fileprivate let highlightTextColor = UIColor.red

    fileprivate let lineWidth: CGFloat = 1              // image pixel
    fileprivate let lineColor = UIColor.black

    fileprivate let markHeightLevel0: CGFloat = 0.35 // largest mark, proportion to the width of the ruler
    fileprivate let markHeightLevel1: CGFloat = 0.30
    fileprivate let markHeightLevel2: CGFloat = 0.20

    // width and depth of the ruler are fixed, the height is varied by the measuring length
    // You may create a ruler with the depth much smaller (say, 0.001)
    // to make it look "flat". However, in the 3D world it is harder to read
    fileprivate let rulerWidth: CGFloat = 0.02 // 2cm
    fileprivate let rulerDepth: CGFloat = 0.02 // 2cm

    /*
     * Internal data
     */
    // Points
    fileprivate let startPoint: SCNVector3
    fileprivate var endPoint = SCNVector3Zero

    // Materials, useful for updating
    fileprivate let faceMaterial = SCNMaterial()
    fileprivate let edgeMaterial = SCNMaterial()
    fileprivate var materialArray = [ SCNMaterial ]()

    // Internal nodes, useful for updating
    fileprivate let endNode = SCNNode()
    fileprivate let nodeGeo = SCNNode()

    init(startPoint: SCNVector3, endPoint: SCNVector3) {
        self.startPoint = startPoint
        super.init()
        self.endPoint = endPoint

        faceMaterial.diffuse.contents = tapeBackgroundColor
        edgeMaterial.diffuse.contents = UIColor.darkGray
        materialArray = [ faceMaterial, faceMaterial, faceMaterial, faceMaterial, edgeMaterial, edgeMaterial]

        createMeasure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(endPoint: SCNVector3) {
        self.endPoint = endPoint

        endNode.position = endPoint
        nodeGeo.geometry = createRulerGeomery()
        nodeGeo.position.y = -startPoint.distance(endPoint)/2
    }
}

// MARK: - Length
extension RulerNode {
    func length() -> Float {
        return min(startPoint.distance(endPoint), MaxMeasureLength)
    }

    func lengthString() -> String {
        return RulerNode.lengthToString(length: length())
    }

    class func lengthToString(length: Float) -> String {
        if length >= 1 {    // 1 meter
            return String(format: "%.2f m", length)
        }
        if length >= 0.01 { // 1 centimeter
            return String(format: "%.1f cm", length * 100)
        }
        return "\(Int(length * 1000)) mm"
    }
}

// MARK: - Ruler
extension RulerNode {

    // Measure is actually a box (scnbox) with the top and the bottom touched to two give points
    fileprivate func createMeasure() {
        //Calcul the height of our line
        let height = length()

        let nodeV1 = SCNNode()
        nodeV1.position = startPoint
        self.addChildNode(nodeV1)

        endNode.position = endPoint
        self.addChildNode(endNode)

        //Align Z axis
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(Double.pi / 2)

        nodeGeo.geometry = createRulerGeomery()
        nodeGeo.position.y = -height/2
        zAlign.addChildNode(nodeGeo)
        nodeV1.addChildNode(zAlign)

        //set constraints direction to end vector
        nodeV1.constraints = [SCNLookAtConstraint(target: endNode)]
    }

    fileprivate func createRulerGeomery() -> SCNGeometry {
        let height = length()

        if let img = createMeasuringTapImage(length: height)?.rotated90() {
            faceMaterial.diffuse.contents = img
        } else {
            faceMaterial.diffuse.contents = UIColor.red
        }

        // The most importance object - ruler
        let geo = SCNBox(width: rulerWidth, height: CGFloat(height), length: rulerDepth, chamferRadius: 0)
        geo.materials = materialArray
        return geo
    }

    /*
     * Create image of the measure
     * We create the image horizontally, thus we don't need to rotate the number when drawing
     * However we create the ruler as a vertical box (scnbox), we need to rotate the image before using
     */
    // TODO: large numbers may have not enough space to display
    fileprivate func createMeasuringTapImage(length: Float) -> UIImage? {
        let lengthInMilimeter = Int(length * 1000)

        if lengthInMilimeter <= 0 {
            return nil
        }

        let height = heightInMilimeter * pixelPerMilimeter
        let size = CGSize(width: CGFloat(lengthInMilimeter) * pixelPerMilimeter, height: height)
        let rect = CGRect(origin: CGPoint.zero, size: size)


        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let attr: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor: textColor
        ]

        let highlightAttr: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor: highlightTextColor
        ]

        ctx.setFillColor(tapeBackgroundColor.cgColor)
        ctx.fill(rect)

        ctx.setLineWidth(lineWidth)

        // Draw marks and numbers
        ctx.beginPath()
        for i in 0 ... lengthInMilimeter {
            ctx.setStrokeColor(lineColor.cgColor)

            let x = CGFloat(i) * pixelPerMilimeter
            ctx.move(to: CGPoint(x: x, y: 0))

            let h: CGFloat = height * (i % 10 == 0 ? markHeightLevel0 : i % 5 == 0 ? markHeightLevel1 : markHeightLevel2)
            ctx.addLine(to: CGPoint(x: x, y: h))
            ctx.move(to: CGPoint(x: x, y: height - h))
            ctx.addLine(to: CGPoint(x: x, y: height))

            // numbers
            if i % 10 == 0 {
                let number = i / 10
                let numberString = "\(number)"
                let textSize = numberString.size(withAttributes: attr)
                var x = max(0, x - textSize.width / 2)
                if x + textSize.width >= size.width {
                    x = size.width - textSize.width - 1
                }
                let textRect = CGRect(x: x, y: (height - textSize.height) / 2, width: textSize.width + 2, height: 1000)
                numberString.draw(in: textRect, withAttributes: number % 10 == 0 ?  highlightAttr : attr)
            }
        }

        ctx.closePath()
        ctx.strokePath()

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

}
