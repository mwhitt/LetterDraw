//
//  ViewController.swift
//  LetterDraw
//
//  Created by Matthew Whittaker on 8/13/19.
//  Copyright © 2019 One Stream Ventures. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var predictLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var currentPredictionString: String = ""
    
    lazy var highlightLayer: CALayer = {
        let layer = CALayer()
        layer.bounds = .zero
        layer.borderWidth = 2
        layer.borderColor = UIColor.green.cgColor
        return layer
    }()
    
    lazy var mnistModel: VNCoreMLModel = {
        return try! VNCoreMLModel(for: MNISTLetterClassifer().model)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predictLabel.isHidden = true
        predictLabel.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPredictions))
        predictLabel.addGestureRecognizer(tap)
        drawView.layer.addSublayer(highlightLayer)
        previewImageView.contentMode = .scaleAspectFit
    }
    
    @objc func showPredictions() {
        let alert = UIAlertController(title: "Top Predictions", message: currentPredictionString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func clearTapped() {
        drawView.lines = []
        drawView.setNeedsDisplay()
        predictLabel.isHidden = true
        previewImageView.image = nil
    }
    
    @IBAction func predictTapped() {
        // Crop image -> Scale -> Grayscale -> ML prediction
        let cv = OpenCVManager()
        let results = cv.boundingRect(for: drawView.asImage())
        
        guard
            let minX = results["minX"] as? NSNumber,
            let minY = results["minY"] as? NSNumber,
            let maxWidth = results["maxWidth"] as? NSNumber,
            let maxHeight = results["maxHeight"] as? NSNumber
            else { return }
        
        let boundingRect = CGRect(
            x: CGFloat(minX.floatValue) / UIScreen.main.scale,
            y: CGFloat(minY.floatValue) / UIScreen.main.scale,
            width: CGFloat(maxWidth.floatValue) / UIScreen.main.scale,
            height: CGFloat(maxHeight.floatValue) / UIScreen.main.scale
        )
        
        let croppedImage = drawView.crop(using: boundingRect)
        let normalized = croppedImage.normalizedSize.grayscale
        
        previewImageView.image = normalized
        predictLetter(normalized.cgImage!)
        saveImage(normalized)
    }
}

// MARK: - Predict Letter in Image

extension ViewController {
    func predictLetter(_ image: CGImage) {
        let ciImage = CIImage(cgImage: image)
        let handler = VNImageRequestHandler(ciImage: ciImage)
        let request = VNCoreMLRequest(model: mnistModel, completionHandler: handleClassification)
        DispatchQueue.global(qos: .userInteractive).async {
            do { try handler.perform([request]) } catch {
                print(error as Any)
            }
        }
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("Unexpected result type from VNCoreMLRequest.") }
        guard let best = observations.first
            else { fatalError("Can't get best result.") }
        
        var labelText = best.identifier
        
        switch Int(best.identifier) {
        case 14: labelText = "Z"
        case 9: labelText = "H"
        case 8: labelText = "I"
        case 5: labelText = "M"
        case 19: labelText = "N"
        case 15: labelText = "O"
        case 26: labelText = "W"
        case 24: labelText = "X"
        case 25: labelText = "Y"
        case 13: labelText = "E"
        case 10: labelText = "P"
        case 16: labelText = "J"
        case 4: labelText = "U"
        case 18: labelText = "T"
        default: break
        }
        
        DispatchQueue.main.async {
            self.predictLabel.text = labelText
            self.predictLabel.isHidden = false
        }
        
        // TRACK TOP 5 RESULTS
        let sortedObservations = observations.sorted(by: {$0.confidence > $1.confidence})
        let top5 = sortedObservations.prefix(5).map({
            "\($0.identifier) = \($0.confidence)"
        })
        currentPredictionString = top5.joined(separator: "\n")
        print("TOP 5")
        print(currentPredictionString)
    }
}

// MARK: - Find Character Bounds in Image

extension ViewController {
    func findCharacterBounds(_ image: CGImage) {
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        // Vision text rectangle
        let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] (request, _) in
            guard let observations = request.results else { print("no result"); return }
            guard let results = observations as? [VNRecognizedObjectObservation] else { return }
            DispatchQueue.main.async {
                self?.drawVisionRequestResults(results)
            }
            
        })
        request.reportCharacterBoxes = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            do { try handler.perform([request]) } catch {
                print(error as Any)
            }
        }
    }
    
    func drawVisionRequestResults(_ results: [VNRecognizedObjectObservation]) {
        let topResult = results.first!
        do {
            var transform = CGAffineTransform.identity
            let parentBounds = drawView.bounds
            transform = transform.scaledBy(x: parentBounds.size.width, y: -parentBounds.size.height)
            transform = transform.translatedBy(x: 0, y: -1)
            let rect = topResult.boundingBox.applying(transform)
            let scaleUp: CGFloat = 0.2
            let biggerRect = rect.insetBy(dx: -rect.size.width * scaleUp, dy: -rect.size.height * scaleUp)
            highlightLayer.frame = biggerRect
        }
    }
}

// MARK: - Save images sent to model to be used for training later

extension ViewController {
    func saveImage(_ image: UIImage) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("characters")
        if !fileManager.fileExists(atPath: path) {
        try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: path)
        let imageName = NSUUID().uuidString + ".jpg"
        let imagePath = url!.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        let imageData = image.jpegData(compressionQuality: 1)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
}
