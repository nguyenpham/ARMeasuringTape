//
//  ViewController.swift
//  ARMeasuringTape
//
//  Created by NguyenPham on 7/8/17.
//  Copyright © 2017 Softgaroo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    /*
     * The measure will be dropped from center point of the device
     * You may change that distance (it is in meter, 0.2 = 0.2meter)
     */
    let MeasureDistanceFromCenterPoint: Float = 0.2

    enum MeasureMode {
        case none, measuring
    }

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    fileprivate var measureMode = MeasureMode.none
    fileprivate var measuringRuler: RulerNode? = nil
    fileprivate var startPoint: SCNVector3?

    fileprivate var rulerArray = [ RulerNode ]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        setupBtns()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @IBAction func cancelBtnTouchUp(_ sender: Any) {
        measuringRuler?.removeFromParentNode()
        measuringRuler = nil
        startPoint = nil

        measureMode = .none
        setupBtns()
        showInfo()
    }

    @IBAction func startBtnTouchUp(_ sender: Any) {
        if let ruler = measuringRuler {
            rulerArray.append(ruler)
        }

        measuringRuler = nil
        startPoint = nil

        measureMode = measureMode == .none ? .measuring : .none
        setupBtns()
        showInfo()
    }

    fileprivate func setupBtns() {
        cancelBtn.isHidden = measureMode == .none
        startBtn.backgroundColor = measureMode == .none ? UIColor.yellow : UIColor.green
    }


    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

        guard measureMode == .measuring,
            let pointOfView = sceneView.pointOfView else {
            return
        }

        let mat = pointOfView.transform
        let delta = SCNVector3(-MeasureDistanceFromCenterPoint * mat.m31, -MeasureDistanceFromCenterPoint * mat.m32, -MeasureDistanceFromCenterPoint * mat.m33)
        let currentPoint = pointOfView.position + delta

        guard let startPoint = startPoint else {
            self.startPoint = currentPoint
            return
        }

        if measuringRuler == nil {
            measuringRuler = RulerNode(startPoint: startPoint, endPoint: currentPoint)
            self.sceneView.scene.rootNode.addChildNode(self.measuringRuler!)
        } else {
            measuringRuler?.update(endPoint: currentPoint)
        }

        showInfo()
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    fileprivate func showInfo() {
        var str = ""
        if let last = rulerArray.last {
            if rulerArray.count > 1 {
                var totalLength: Float = 0
                for ruler in rulerArray {
                    totalLength += ruler.length()
                }

                str += "Total: \(RulerNode.lengthToString(length: totalLength)), "
            }
            str += "Last: \(last.lengthString()), "
        }

        if let ruler = measuringRuler {
            str += "Measuring: \(ruler.lengthString())"
        }

        DispatchQueue.main.async {
            self.infoLabel.text = str
        }
    }

}
