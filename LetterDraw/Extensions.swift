import UIKit
import AVFoundation

extension UIImage {
    
    var grayscale: UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 28, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
    
    var normalizedSize: UIImage {
        let newSize = CGSize(width: 28, height: 28)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: newSize))
        imageView.backgroundColor = .black
        imageView.image = self
        imageView.contentMode = .scaleAspectFit
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.main.scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
}
