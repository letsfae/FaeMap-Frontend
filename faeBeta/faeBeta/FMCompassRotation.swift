//
//  FMCompassRotation.swift
//  faeBeta
//
//  Created by Yue on 7/17/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func loadGestures() {
        rotationGesture = UIRotationGestureRecognizer()
        rotationGesture.delaysTouchesEnded = false
        rotationGesture.cancelsTouchesInView = true
        rotationGesture.delaysTouchesBegan = false
        rotationGesture.addTarget(self, action: #selector(self.handleRotation(_:)))
        self.view.addGestureRecognizer(rotationGesture)
        
        panGesture = UIPanGestureRecognizer()
        panGesture.cancelsTouchesInView = true
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = true
        panGesture.addTarget(self, action: #selector(self.handleSwipe(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.cancelsTouchesInView = true
        pinchGesture.delaysTouchesBegan = false
        pinchGesture.delaysTouchesEnded = true
        pinchGesture.addTarget(self, action: #selector(self.pinchGestureRecognizer(_:)))
        self.view.addGestureRecognizer(pinchGesture)
        
        rotationGesture.delegate = self
        pinchGesture.delegate = self
        panGesture.delegate = self
    }
    
    // Helper: Detect when the MapView changes                                                  *
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = faeMapView.subviews[0]
        // Look through gesture recognizers to determine whether this region
        // change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizerState.began ||
                    recognizer.state == UIGestureRecognizerState.ended {
                    return true
                }
            }
        }
        return false
    }
    //                                                                                          *
    // ******************************************************************************************
    
    // ******************************************************************************************
    //                                                                                          *
    // Helper: Needed to be allowed to recognize gestures simultaneously to the MapView ones.   *
    // UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //                                                                                          *
    // ******************************************************************************************
    
    // ******************************************************************************************
    //                                                                                          *
    // Helper: Use CADisplayLink to fire a selector at screen refreshes to sync with each       *
    // frame of MapKit's animation
    
    func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(self.refreshCompassHeading(_:)))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    //                                                                                          *
    // ******************************************************************************************
    
    // ******************************************************************************************
    //                                                                                          *
    // Detect if the user starts to interact with the map...                                    *
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        
        if mapChangedFromUserInteraction {
            
            // Map interaction. Set up a CADisplayLink.
            setUpDisplayLink()
        }
    }
    //                                                                                          *
    // ******************************************************************************************
    //                                                                                          *
    // ... and when he stops.                                                                   *
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if mapChangedFromUserInteraction {
            
            // Final transform.
            // If all calculations would be correct, then this shouldn't be needed do nothing.
            // However, if something went wrong, with this final transformation the compass
            // always points to the right direction after the interaction is finished.
            // Making it a 500 ms animation provides elasticity und prevents hard transitions.
            
            UIView.animate(withDuration: 0.5, animations: {
                self.btnToNorth.transform =
                    CGAffineTransform(rotationAngle: CGFloat(Double.pi * -mapView.camera.heading) / 180.0)
            })
            
            // You may want this here to work on a better rotate out equation. :)
            
            let stoptime = Date.timeIntervalSinceReferenceDate
            print("Needed time to rotate out:", stoptime - startRotateOut, "with velocity",
                  remainingVelocityAfterUserInteractionEnded, ".")
            print("Velocity decrease per sec:", (Double(remainingVelocityAfterUserInteractionEnded)
                / (stoptime - startRotateOut)))
            
            // Clean up for the next rotation.
            
            remainingVelocityAfterUserInteractionEnded = 0
            initialMapGestureModeIsRotation = nil
            if let _ = displayLink {
                displayLink.invalidate()
            }
        }
    }
    //                                                                                          *
    // ******************************************************************************************
    
    // ******************************************************************************************
    //                                                                                          *
    // This is our main function. The display link calls it once every display frame.           *
    
    @objc func refreshCompassHeading(_ sender: AnyObject) {
        
        // If the gesture mode is not determinated or user is adjusting pitch
        // we do obviously nothing here. :)
        if initialMapGestureModeIsRotation == nil || !initialMapGestureModeIsRotation! {
            return
        }
        
        let rotationInRadian: CGFloat
        
        if remainingVelocityAfterUserInteractionEnded == 0 {
            
            // This is the normal case, when the map is beeing rotated.
            rotationInRadian = rotationGesture.rotation
            
        } else {
            
            // velocity is > 0 or < 0.
            // This is the case when the user ended the gesture and there is
            // still some momentum left.
            
            let currentTime = Date.timeIntervalSinceReferenceDate
            let deltaTime = currentTime - prevTime
            
            // Calculate new remaining velocity here.
            // This is only very empiric and leaves room for improvement.
            // For instance I noticed that in the middle of the translation
            // the needle rotates a bid faster than the map.
            let SLOW_DOWN_FACTOR: CGFloat = 1.87
            let elapsedTime = currentTime - startRotateOut
            
            // Mathematicians, the next line is for you to play.
            currentlyRemainingVelocity -=
                currentlyRemainingVelocity * CGFloat(elapsedTime) / SLOW_DOWN_FACTOR
            
            let rotationInRadianSinceLastFrame =
                currentlyRemainingVelocity * CGFloat(deltaTime)
            rotationInRadian = prevRotationInRadian + rotationInRadianSinceLastFrame
            
            // Remember for the next frame.
            prevRotationInRadian = rotationInRadian
            prevTime = currentTime
        }
        
        // Convert radian to degree and get our long-desired new heading.
        let rotationInDegrees = Double(rotationInRadian * (180 / CGFloat(Double.pi)))
        let newHeading = -faeMapView.camera.heading + rotationInDegrees
        
        // No real difference? No expensive transform then.
        let difference = abs(newHeading - prevHeading)
        if difference < 0.001 {
            return
        }
        
        // Finally rotate the compass.
        btnToNorth.transform =
            CGAffineTransform(rotationAngle: CGFloat(Double.pi * newHeading) / 180.0)
        
        // Remember for the next frame.
        prevHeading = newHeading
    }
    //                                                                                          *
    // ******************************************************************************************
    
    // ******************************************************************************************
    //                                                                                          *
    // UIRotationGestureRecognizer                                                              *
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        
        if initialMapGestureModeIsRotation == nil {
            initialMapGestureModeIsRotation = true
        } else if !initialMapGestureModeIsRotation! {
            // User is not in rotation mode.
            return
        }
        
        if sender.state == .ended {
            if sender.velocity != 0 {
                
                // Velocity left after ending rotation gesture. Decelerate from remaining
                // momentum. This block is only called once.
                remainingVelocityAfterUserInteractionEnded = sender.velocity
                currentlyRemainingVelocity = remainingVelocityAfterUserInteractionEnded
                startRotateOut = Date.timeIntervalSinceReferenceDate
                prevTime = startRotateOut
                prevRotationInRadian = rotationGesture.rotation
            }
        }
    }
    //                                                                                          *
    // ******************************************************************************************
    //                                                                                          *
    // Yes, there is also a SwypeGestureRecognizer, but the length for being recognized as      *
    // is far too long. Recognizing a 2 finger swype up or down with a PanGestureRecognizer
    // yields better results.
    
    @objc func handleSwipe(_ sender: UIPanGestureRecognizer) {
        
        // After a certain altitude is reached, there is no pitch possible.
        // In this case the 3D perspective change does not work and the rotation is initialized.
        // Play with this one.
        let MAX_PITCH_ALTITUDE: Double = 100000
        
        // Play with this one for best results detecting a swype. The 3D perspective change is
        // recognized quite quickly, thats the reason a swype recognizer here is of no use.
        let SWYPE_SENSITIVITY: CGFloat = 0.5 // play with this one
        
        if let _ = initialMapGestureModeIsRotation {
            // Gesture mode is already determined.
            // Swypes don't care us anymore.
            return
        }
        
        if faeMapView.camera.altitude > MAX_PITCH_ALTITUDE {
            // Altitude is too high to adjust pitch.
            return
        }
        
        let panned = sender.translation(in: faeMapView)
        
        if fabs(panned.y) > SWYPE_SENSITIVITY {
            // Initial swype up or down.
            // Map gesture is most likely a 3D perspective correction.
            initialMapGestureModeIsRotation = false
        }
    }
    //                                                                                          *
    // ******************************************************************************************
    //                                                                                          *
    
    @objc func pinchGestureRecognizer(_ sender: UIPinchGestureRecognizer) {
        
        // pinch is zoom. this always enables rotation mode.
        if initialMapGestureModeIsRotation == nil {
            initialMapGestureModeIsRotation = true
            // Initial pinch detected. This is normally a zoom
            // which goes in hand with a rotation.
        }
    }
    //                                                                                          *
    // ******************************************************************************************
}
