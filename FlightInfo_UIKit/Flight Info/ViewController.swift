/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {
    @IBOutlet var background: UIImageView!
    
    @IBOutlet var summaryIcon: UIImageView!
    @IBOutlet var summary: UILabel!
    
    @IBOutlet var flightNumberLabel: UILabel!
    @IBOutlet var gateNumberLabel: UILabel!
    @IBOutlet var originLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var plane: UIImageView!
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusBanner: UIImageView!
    
    private let snowView = SnowView( frame: .init(x: -150, y:-100, width: 300, height: 50) )
}

//MARK:- UIViewController
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the snow effect layer
        let snowClipView = UIView( frame: view.frame.offsetBy(dx: 0, dy: 50) )
        snowClipView.clipsToBounds = true
        snowClipView.addSubview(snowView)
        view.addSubview(snowClipView)
        
        // Start rotating the flights
        changeFlight(to: .londonToParis, animated: false)
    }
}

private extension ViewController {
    //MARK:- Animations
    
    func fade(to image: UIImage, showEffects: Bool) {
        // Create & Set up temp view.
        let tempView = UIImageView(frame: background.frame)
        tempView.image = image
        tempView.alpha = 0
        tempView.center.y += 20
        tempView.bounds.size.width = background.bounds.width * 1.3
        background.superview!.insertSubview(tempView, aboveSubview: background)
        
        UIView.animate(
            withDuration: 1 / 2,
            animations: {
                // Fade temp view in.
                tempView.alpha = 1
                tempView.alpha = 1
                tempView.center.y -= 20
                tempView.bounds.size = self.background.bounds.size
                
                // Fade snow effect.
                //self.snowView.alpha = showEffects ? 1 : 0
            },
            completion: { _ in
                // Update background view & remove temp view.
                self.background.image = image
                tempView.removeFromSuperview()
            }
        )
        
        // When you implement separated animation for fading snow effet, you can give more delay so that it's different with background fading. Sometimes it's more natural.
        UIView.animate(
            withDuration: 1.5, delay: 0,
            options: .curveEaseOut,
            animations: { self.snowView.alpha = showEffects ? 1 : 0 }
        )
    }
    
    func move(label: UILabel, text: String, offset: CGPoint) {
        // Create & set up temp label.
        let  tempLabel = duplicate(label)
        tempLabel.text = text
        tempLabel.transform = .init(translationX: offset.x, y: offset.y)
        tempLabel.alpha = 0
        view.addSubview(tempLabel)
        
        UIView.animate(
            withDuration: 0.5, delay: 0,
            options: .curveEaseIn,
            animations: {
                // Fade out and translate the real label.
                label.transform = .init(translationX: offset.x, y: offset.y)
                label.alpha = 0
                
                // Fade in and translate the temp label.
                tempLabel.transform = .identity
                tempLabel.alpha = 1
            },
            completion: { _ in
                // Update the real label and remove the temp label.
                label.text = text
                label.alpha = 1
                label.transform = .identity
                tempLabel.removeFromSuperview()
            }
        )
    }
    
    func cubeTransition(label: UILabel, text: String) {
        // Create and set up temp label.
        let tempLabel = duplicate(label)
        tempLabel.text = text
        let tempLabelOffset = label.frame.size.height / 2
        let scale = CGAffineTransform(scaleX: 1, y: 0.1)
        let translate = CGAffineTransform(translationX: 0, y: tempLabelOffset)
        tempLabel.transform = scale.concatenating(translate)
        label.superview!.addSubview(tempLabel)
        
        UIView.animate(
            withDuration: 0.5, delay: 0,
            options: .curveEaseOut,
            animations: {
                // Scale temp label down and translate up.
                tempLabel.transform = .identity
                
                // Scale real label down and translate up.
                label.transform = scale.concatenating(translate.inverted())
            },
            completion: { _ in
                // Update the real label's text and reset its transform.
                label.text = tempLabel.text
                label.transform = .identity
                
                tempLabel.removeFromSuperview()
            }
        )
    }
    
    func depart() {
        let originalCenter = plane.center
        
        UIView.animateKeyframes(
            withDuration: 1.5, delay: 0,
            animations: { [plane = self.plane!] in
                //Move plane right and up.
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                    plane.center.x += 80
                    plane.center.y -= 10
                })
                
                // Roate the plane.
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                    plane.transform = .init(rotationAngle: -.pi / 8)
                })
                
                // Move the plane right and up off screen, while fading out.
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                    plane.center.x += 100
                    plane.center.y -= 50
                    plane.alpha = 0
                })
                
                // Move the plane just off left side, reset transform and height.
                UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.01, animations: {
                    plane.transform = .identity
                    plane.center = .init(x: 0, y: originalCenter.y)
                })
                
                // Move the plane back to original position and fade in.
                UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45, animations: {
                    plane.alpha = 1
                    plane.center = originalCenter
                })
            }
        )
    }
    
    func changeSummary(to summaryText: String) {
        // Add a one second key frame animation.
        // Make use of delay method down below.
        UIView.animateKeyframes(
            withDuration: 1.0, delay: 0,
            animations: { [summary = self.summary!] in
                // Move label upward.
                UIView.addKeyframe(
                    withRelativeStartTime: 0, relativeDuration: 0.5,
                    animations: { summary.center.y -= 100 }
                )
                // Move label down.
                UIView.addKeyframe(
                    withRelativeStartTime: 0.5, relativeDuration: 0.2,
                    animations: { summary.center.y += 100 }
                )
            }
        )
        delay(seconds: 0.5, execute: { self.summary.text = summaryText })
    }
    
    func changeFlight(to flight: Flight, animated: Bool = false) {
        // populate the UI with the next flight's data
        flightNumberLabel.text = flight.number
        gateNumberLabel.text = flight.gateNumber

        if animated {
            fade(to: UIImage(named: flight.weatherImageName)!, showEffects: flight.showWeatherEffects)
            
            let offset = CGPoint(x: 0, y: -60)
            move(label: originLabel, text: flight.origin, offset: offset)
            move(label: destinationLabel, text: flight.destination, offset: offset)
            
            cubeTransition(label: statusLabel, text: flight.status)
            depart()
            changeSummary(to: flight.summary)
        } else {
            background.image = UIImage(named: flight.weatherImageName)
            originLabel.text = flight.origin
            destinationLabel.text = flight.destination
            statusLabel.text = flight.status
            summary.text = flight.summary
        }
        
        // schedule next flight
        delay(seconds: 3) {
            self.changeFlight(
                to: flight.isTakingOff ? .parisToRome : .londonToParis,
                animated: true
            )
        }
    }
    
    //MARK:- utility methods
    func duplicate(_ label: UILabel) -> UILabel {
        let newLabel = UILabel(frame: label.frame)
        newLabel.font = label.font
        newLabel.textAlignment = label.textAlignment
        newLabel.textColor = label.textColor
        newLabel.backgroundColor = label.backgroundColor
        return newLabel
    }
}

private func delay(seconds: TimeInterval, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
}
