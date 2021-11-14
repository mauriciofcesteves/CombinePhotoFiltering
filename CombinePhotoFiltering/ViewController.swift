//
//  ViewController.swift
//  CombinePhotoFiltering
//
//  Created by Mauricio Esteves on 2021-11-13.
//

import Combine
import Foundation
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sepiaFilter: UIButton!
    @IBOutlet weak var bloomFilter: UIButton!

    private var cancellable: AnyCancellable?
    private var context = CIContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //Is triggered when a navigation is happening
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController, let photosCVC = navigationController.viewControllers.first as? PhotosCollectionViewController else {
            fatalError("Segue PhotosCollectionViewController was not found.")
        }

        cancellable = photosCVC.$image.sink() { [weak self] photo in
            guard let photo = photo else { return }

            DispatchQueue.main.async {
                self?.updateUI(with: photo)
            }
        }
    }

    @IBAction func applySepiaFilterImageTouched(_ sender: Any) {
        guard let sourceImage = self.imageView.image else {
            return
        }

        guard let input = CIImage(image: sourceImage) else { return }

        guard let filteredImage = sepiaFilter(input, intensity: 0.9) else {
            return
        }

        self.imageView.image = filteredImage
    }

    @IBAction func applyBloomFilterImageTouched(_ sender: Any) {
        guard let sourceImage = self.imageView.image else {
            return
        }

        guard let input = CIImage(image: sourceImage) else { return }

        guard let filteredImage = bloomFilter(input, intensity: 1, radius: 5) else {
            return
        }

        self.imageView.image = filteredImage
    }

    func sepiaFilter(_ input: CIImage, intensity: Double) -> UIImage? {
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)

        guard let outputImage = sepiaFilter?.outputImage else { return nil }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        return nil
    }

    func bloomFilter(_ input:CIImage, intensity: Double, radius: Double) -> UIImage? {
        let bloomFilter = CIFilter(name:"CIBloom")
        bloomFilter?.setValue(input, forKey: kCIInputImageKey)
        bloomFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        bloomFilter?.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = bloomFilter?.outputImage else { return nil }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        return nil
    }

    private func updateUI(with photo: UIImage) {
        self.imageView.image = photo
        self.bloomFilter.isHidden = false
        self.sepiaFilter.isHidden = false
    }
}
