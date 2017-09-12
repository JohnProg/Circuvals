import UIKit

struct Circle {
    let foreground: CAShapeLayer
    let background: CAShapeLayer
}

class CircleTimerView: UIView {
    static let π = CGFloat.pi

    @IBInspectable var lineWidth:CGFloat = 10.0
    @IBInspectable var gap:CGFloat = 2.0
    var backgroundCircleColor:UIColor = UIColor.lightGray
    
    var circles = [Circle]()
    var numberOfCircles = 3 {
        didSet {
            configureSublayers()
        }
    }
    
    private func setValue(_ value:Float, layer: CAShapeLayer) {
        layer.removeAllAnimations()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.strokeEnd = CGFloat(value)
        CATransaction.commit()
        }

    private func setValue(_ value: Float, inTime: Double, layer: CAShapeLayer) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(inTime)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        layer.strokeEnd = CGFloat(value)
        CATransaction.commit()
    }
    
    func setPercentage(_ value:Float, at: Int) {
        let circle = circles[at]
        setValue(value, layer: circle.foreground)
    }
    
    func setPercentage(_ value: Float, at: Int, inTime: Double) {
        let circle = circles[at]
        setValue(value, inTime: inTime, layer: circle.foreground)
    }

    let startAngle = 3/2 * π
    let endAngle  =  3/2 * π + (2 * π)

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSublayers()
    }
    
    private func configureSublayers() {
        for _ in 1...numberOfCircles {
            let backgroundLayer = CAShapeLayer()
            backgroundLayer.fillColor = UIColor.clear.cgColor
            backgroundLayer.lineWidth = lineWidth * 0.99
            backgroundLayer.strokeColor = backgroundCircleColor.cgColor
            layer.addSublayer(backgroundLayer)
            let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.lineWidth = lineWidth
            layer.addSublayer(circleLayer)
            circles.append(Circle(foreground: circleLayer, background: backgroundLayer))
        }
    }
    
    override internal func layoutSubviews() {
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let arcCenter = CGPoint(x: bounds.width / 2.0,
                                y: bounds.height / 2.0)
        let maxRadius = (min(bounds.height, bounds.width)/2.0) - (lineWidth/2.0)
        for (index, element) in circles.enumerated() {
            let radius = maxRadius - CGFloat(index) * (gap + lineWidth)
            let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
            element.background.path = path
            element.foreground.path = path
        }
    }

}
