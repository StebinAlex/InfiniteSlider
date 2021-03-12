//
//  InfiniteSlider.swift
//  InfiniteSlider
//
//  Created by Stebin Alex on 10/03/21.
//

import UIKit

public protocol InfiniteSliderDelegate {
    func current(index: Int)
    func clicked(index: Int)
}


public class InfiniteSlider: UIView {

    public var placeHolderImage: UIImage?
    private var index = 0
    private var count = 0
    private var manualMove = false
    private let scrollView = UIScrollView()
    public var delegate: InfiniteSliderDelegate?
    private var timer = Timer()

    public var images: [UIImage] = [] {
        didSet {
            setSlider()
        }
    }

    public var imageUrls: [String] = [] {
        didSet {
            setSlider()
        }
    }

    public var timeInterval: Double = 4 {
        didSet {
            setTimer()
        }
    }

    private var updatedImages: [UIImage] {
        get {
            var imgs: [UIImage] = images.compactMap({$0})
            if imgs.count > 1 {
                imgs.append(images.first!)
            }
            return imgs
        }
    }

    private var updatedImageUrls: [String] {
        get {
            var imgs: [String] = imageUrls.compactMap({$0})
            if imgs.count > 1 {
                imgs.append(imageUrls.first!)
            }
            return imgs
        }
    }

    fileprivate func setTimer() {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(moveImage), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(moveImage), userInfo: nil, repeats: true)
        }
    }

    public override init(frame: CGRect){
        super.init(frame: frame)
        scrollView.frame = self.frame
        scrollView.center = self.center
        scrollView.isPagingEnabled = true
        self.addSubview(scrollView)
        setTimer()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setImage(_ imageView: UIImageView, _ i: Int) {
        if updatedImages.count > 0 {
            imageView.image = updatedImages[i]
        } else {
            let indicator = UIActivityIndicatorView()
            indicator.center = imageView.center
            imageView.addSubview(indicator)
            indicator.startAnimating()
            if let p = placeHolderImage {
                imageView.image = p
            }
            if let url: URL = URL(string: updatedImageUrls[i]) {
                getImage(from: url) { (image, error) -> (Void) in
                    if error == nil, let image = image {
                        DispatchQueue.main.async {
                            imageView.image = image
                            indicator.stopAnimating()
                        }
                    }
                }

            }
        }
    }

    private func setSlider() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        if updatedImages.count > 0 {
            count = updatedImages.count
        } else {
            count = updatedImageUrls.count
        }

        scrollView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: width, height: height)
        for i in 0..<count {
            let imageView = UIImageView()
            let btn = UIButton()
            btn.backgroundColor = .clear
            btn.tag = i
            imageView.contentMode = .scaleToFill
            btn.addTarget(self, action: #selector(btnClicked(_:)), for: .touchUpInside)
            let xPosition = width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            btn.frame = imageView.frame
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
            scrollView.addSubview(btn)
            setImage(imageView, i)
        }
    }

    fileprivate func animateImage() {
        let width = self.frame.size.width
        if index >= count {
            index = 0
            scrollView.contentOffset.x = 0
            moveImage()
        } else {
            UIView.animate(withDuration: timeInterval/2) { [self] in
                scrollView.contentOffset.x = width * CGFloat(index)
            }
            delegate?.current(index: index)
        }
    }

    @objc private func moveImage() {
        if count == 0 { return }
        if manualMove {
            manualMove = false
        } else {
            index += 1
            animateImage()
        }
    }

    public func moveSliderLeft() {
        if index > 0 {
            index -= 1
        }
        manualMove = true
        animateImage()
    }
    public func moveSliderRight() {
        if index < count {
            index += 1
        }
        manualMove = true
        animateImage()
    }

    @objc private func btnClicked(_ sender: UIButton) {
        delegate?.clicked(index: index)
    }

}

extension InfiniteSlider: UIScrollViewDelegate {
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.x > 0) {
            if index > 0 {
                index -= 1
            }
        } else {
            if index < count {
                index += 1
            }
        }
    }
}

private class ImageCache {
    private init() {}
    static let shared = NSCache<NSString, UIImage>()
}


extension InfiniteSlider {
    private func getImage(from url: URL, completion: @escaping ((UIImage?, Error?)->(Void))) {
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            print("Image from cache")
            completion(cachedImage, nil)
        }

        getData(from: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else if let imgData = data, let image = UIImage(data: imgData) {
                ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                print("Image from cache")
                completion(image, nil)
            }
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
