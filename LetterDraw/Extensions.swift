import UIKit
import AVFoundation
import CoreGraphics

extension UIImage {
    
    var grayscale: UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)
        context!.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        let imageRef = context!.makeImage()
        return UIImage(cgImage: imageRef!)
    }
    
    var normalizedSize: UIImage {
        let newSize = CGSize(width: 28, height: 28)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: newSize))
        imageView.backgroundColor = .black
        imageView.image = self
        imageView.contentMode = .scaleAspectFit
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
}
