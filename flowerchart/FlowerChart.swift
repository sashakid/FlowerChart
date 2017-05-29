//
//  FlowerChart.swift
//  flowerchart
//
//  Created by drinkius on 22/03/16.
//  Copyright © 2016 Alexander Telegin. All rights reserved.
//

import UIKit

let chartColor = UIColor.gray
let chartBackgroundColor = UIColor.black
let chartTextColor = UIColor.white
let chartSelectionColor = UIColor.yellow

protocol FlowerChartDelegate: class {
    func flowerChartTapped(index: Int)
}

class FlowerChart: UIView {
    
    fileprivate var petalCanvas: UIView!
    fileprivate var data = [Double]()
    fileprivate var labels = [String]()
    fileprivate var petalsArray = [UIView]()
    fileprivate var selection: CAShapeLayer?
    fileprivate var selectedIndex = -1
    weak var delegate: FlowerChartDelegate?

    //MARK: Public
    
    init(petalCanvas: UIView, data: Array<Double>, labels: Array<String>) {
        petalCanvas.backgroundColor = chartBackgroundColor

        self.petalCanvas = petalCanvas
        self.data = data
        self.labels = labels
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawFlower() {
        //TODO: need to fix that logic with many views, touches and delegate
        //add the caller to petalCanvas as the lowest view to control touching (delegate != nil for that view)
        petalCanvas.addSubview(self)
        
        func petalInitialization(_ i: Int) -> Void {
            let petalView = FlowerChart(petalCanvas: petalCanvas, data: data, labels: labels)
            petalView.frame = petalCanvas.bounds
            //TODO: Need to fix logic with right datasource and gaps to avoid ["data", "", "data", "", ...]
            if i % 2 == 0 {
                petalCanvas.addSubview(petalView)
            }
            petalsArray.append(petalView)
            petalView.drawPetal(i)
        }
        
        for i in 0 ..< data.count {
            petalInitialization(i)
            drawLabels(i, size: CGFloat(data[i]))
        }
        
        scalePetals()
    }
    
    //MARK: Private
    
    private func drawPetal(_ petalNumber: Int) {
        if petalNumber % 2 == 1 {
            return
        }
        
        let pi: CGFloat = CGFloat(M_PI)
        let strokeColor: UIColor = UIColor.clear
        
        let maxSize = min(petalCanvas.bounds.width - 20, petalCanvas.bounds.height - 20)
        let outlineWidth: CGFloat = 1
        let arcRadius: CGFloat = maxSize / 2
        let center = CGPoint(x: petalCanvas.bounds.width / 2, y: petalCanvas.bounds.height / 2)
        let startAngle = CGFloat(0) + CGFloat(petalNumber) * 2 * pi / CGFloat(data.count) - pi / 2
        let endAngle = startAngle + 2 * pi / CGFloat(data.count)
        
        let petalPath = UIBezierPath(
            arcCenter: center,
            radius:  arcRadius - outlineWidth / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        petalPath.addLine(to: center)
        petalPath.close()
        
        let petalShapeLayer: CAShapeLayer = CAShapeLayer()
        petalShapeLayer.path = petalPath.cgPath
        petalShapeLayer.fillColor = chartColor.cgColor
        petalShapeLayer.lineWidth = outlineWidth
        petalShapeLayer.strokeColor = strokeColor.cgColor
        self.layer.addSublayer(petalShapeLayer)
    }
    
    private func drawLabels(_ petalNumber: Int, size: CGFloat) {
        if petalNumber % 2 == 1 {
            return
        }
        let pi: CGFloat = CGFloat(M_PI)
        let center = CGPoint(x: petalCanvas.bounds.width / 2, y: petalCanvas.bounds.height / 2)
        let startAngle = CGFloat(0) + CGFloat(petalNumber) * 2 * pi / CGFloat(data.count) - pi / 2
        let endAngle = startAngle + 2 * pi / CGFloat(data.count)
        let midPointAngle = (startAngle + endAngle) / 2.0
        let targetPoint = CGPoint(x: center.x + (size * 16) * cos(midPointAngle), y: center.y + (size * 16) *  sin(midPointAngle))
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = chartTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "\(labels[petalNumber])\n\(Int(data[petalNumber] * 10))%"
        label.sizeToFit()
        label.center = targetPoint
        petalCanvas.addSubview(label)
    }
    
    private func scalePetals() {
        for i in petalsArray.indices.suffix(from: 0) {
            let scale = CGAffineTransform(scaleX: 0.6, y: 0.6)
            let rotate = CGAffineTransform(rotationAngle: 360)
            let petalToSet = petalsArray[i]
            let currentSize = CGFloat(data[i])
            
            petalToSet.transform = scale.concatenating(rotate)
            petalToSet.alpha = 0
            
            UIView.animate(
                withDuration: 0.0,
                animations: { () -> Void in
                    let scale = CGAffineTransform(scaleX: currentSize / 10, y: currentSize / 10)
                    let rotate = CGAffineTransform(rotationAngle: 0)
                    petalToSet.transform = scale.concatenating(rotate)
                    petalToSet.alpha = 1
            }, completion: { (finished: Bool) -> Void in
                
            })
        }
    }
}

//MARK: UIResponder

extension FlowerChart {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            selection?.removeFromSuperlayer()
            selection = nil
            
            let currentPoint = touch.location(in: self)
            var angle = getAngle(a: currentPoint, b: self.center)
            var petalNumberTouched = 0
            if data.count > 0 {
                let onePetalAngle = 360 / data.count
                if angle >= 0 {
                    petalNumberTouched = Int(angle) / onePetalAngle
                } else {
                    angle += 360
                    petalNumberTouched = Int(angle) / onePetalAngle
                }
            }
            
            if petalNumberTouched % 2 == 1 {
                //we tapped gap
                return
            }
            
            if selectedIndex != petalNumberTouched {
                let pi: CGFloat = CGFloat(M_PI)
                let maxSize = min(petalCanvas.bounds.width, petalCanvas.bounds.height)
                let outlineWidth: CGFloat = 1
                let arcRadius: CGFloat = maxSize / 2
                let center = CGPoint(x: petalCanvas.bounds.width / 2, y: petalCanvas.bounds.height / 2)
                let startAngle = CGFloat(0) + CGFloat(petalNumberTouched) * 2 * pi / CGFloat(data.count) - pi / 2
                let endAngle = startAngle + 2 * pi / CGFloat(data.count)
                
                let petalPath = UIBezierPath(
                    arcCenter: center,
                    radius: arcRadius - outlineWidth / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true
                )
                petalPath.addLine(to: center)
                petalPath.close()
                
                selection = CAShapeLayer()
                selection?.path = petalPath.cgPath
                selection?.fillColor = UIColor.clear.cgColor
                selection?.lineWidth = outlineWidth
                selection?.strokeColor = chartSelectionColor.cgColor
                petalCanvas.layer.addSublayer(selection!)
                
                selectedIndex = petalNumberTouched
                
                for chart in (superview?.subviews)! {
                    if chart is FlowerChart {
                        let chart = chart as! FlowerChart
                        if chart.delegate != nil {
                            chart.delegate?.flowerChartTapped(index: selectedIndex)
                            break
                        }
                    }
                }
            } else {
                selectedIndex = -1
            }
        }
    }
}

//MARK: Helpers

extension FlowerChart {
    func getAngle(a: CGPoint, b: CGPoint) -> CGFloat {
        let x = a.x
        let y = a.y
        let dx = b.x - x
        let dy = b.y - y
        let radians = atan2(-dx, dy)            // in radians
        let degrees = radians * 180 / 3.14      // in degrees
        return degrees
    }
}
