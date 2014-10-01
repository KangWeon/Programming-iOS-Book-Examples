
//  Mandelbrot drawing code based on https://github.com/ddeville/Mandelbrot-set-on-iPhone

import UIKit

class MyMandelbrotView : UIView {

    // best to run on device, because we want a slow processor in order to see the delay
    // you can increase the size of MANDELBROT_STEPS to make even more of a delay
    // but on my device, there's plenty of delay as is!
    
    // let MANDELBROT_STEPS = 200
    
    var bitmapContext: CGContext!
    var odd = false
    
    var queue : NSOperationQueue = {
        let q = NSOperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    /*
    // jumping-off point: draw the Mandelbrot set
    func drawThatPuppy () {
        self.makeBitmapContext(self.bounds.size)
        let center = CGPointMake(self.bounds.midX, self.bounds.midY)
        self.drawAtCenter(center, zoom:1)
        self.setNeedsDisplay()
    }
*/
    
    func drawThatPuppy () {
        let center = CGPointMake(self.bounds.midX, self.bounds.midY)
        let op = MyMandelbrotOperation(size: self.bounds.size, center: center, zoom: 1)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "operationFinished:", name: "MyMandelbrotOperationFinished", object: op)
        self.queue.addOperation(op)
    }
    
    // create instance variable
    func makeBitmapContext(size:CGSize) {
        var bitmapBytesPerRow : UInt = UInt(size.width * 4)
        bitmapBytesPerRow += (16 - (bitmapBytesPerRow % 16)) % 16
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let prem : CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(nil, UInt(size.width), UInt(size.height), 8, bitmapBytesPerRow, colorSpace, prem)
        self.bitmapContext = context
    }
    
// ==== this material is now moved into an NSOperation
/*


    func isInMandelbrotSet(re:Float, _ im:Float) -> Bool {
        var fl = true
        var x : Float = 0
        var y : Float = 0
        var nx : Float = 0
        var ny : Float = 0
        for _ in 0 ..< MANDELBROT_STEPS {
            nx = x*x - y*y + re
            ny = 2*x*y + im
            if nx*nx + ny*ny > 4 {
                fl = false
                break
            }
            x = nx
            y = ny
        }
        return fl
    }
    
    func drawAtCenter(center:CGPoint, zoom:CGFloat) {
        CGContextSetAllowsAntialiasing(self.bitmapContext, false)
        CGContextSetRGBFillColor(self.bitmapContext, 0, 0, 0, 1)
        var re : CGFloat
        var im : CGFloat
        let maxi = Int(self.bounds.size.width)
        let maxj = Int(self.bounds.size.height)
        for i in 0 ..< maxi {
            for j in 0 ..< maxj {
                re = (CGFloat(i) - 1.33 * center.x) / 160
                im = (CGFloat(j) - 1.0 * center.y) / 160
                
                re /= zoom
                im /= zoom
                
                if (isInMandelbrotSet(Float(re), Float(im))) {
                    CGContextFillRect (self.bitmapContext, CGRectMake(CGFloat(i), CGFloat(j), 1.0, 1.0))
                }
            }
        }
    }
    
    */
    
    // ==== end of material moved to NSOperation

    // warning! called on background thread
    func operationFinished(n:NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.redrawWithOperation(n.object as MyMandelbrotOperation)
        }
    }
    
    // now we're back on the main thread {
    func redrawWithOperation (op : MyMandelbrotOperation) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "MyMandelbrotOperationFinished", object: op)
        self.bitmapContext = op.bitmapContext
        self.setNeedsDisplay()
    }

    // turn pixels of self.bitmapContext into CGImage, draw into ourselves
    
    override func drawRect(rect: CGRect) {
        if self.bitmapContext != nil {
            let context = UIGraphicsGetCurrentContext()
            let im = CGBitmapContextCreateImage(self.bitmapContext)
            CGContextDrawImage(context, self.bounds, im)
            self.odd = !self.odd
            self.backgroundColor = self.odd ? UIColor.greenColor() : UIColor.redColor()
        }
    }
    
    deinit {
        self.queue.cancelAllOperations()
    }

    
}
