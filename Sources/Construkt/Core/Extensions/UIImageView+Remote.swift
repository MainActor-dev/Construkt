import UIKit

// Simple Image Cache to avoid re-downloading
fileprivate let imageCache: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.countLimit = 200 // Limit to 200 images
    cache.totalCostLimit = 1024 * 1024 * 200 // 200 MB limit
    return cache
}()

public class ImageCache {
    public static func clear() {
        imageCache.removeAllObjects()
        URLCache.shared.removeAllCachedResponses()
    }
}

// Associated object key for storing the current URL
private var currentTaskKey: UInt8 = 0

public extension UIImageView {
    
    /// Asynchronously fetches and assigns an image from a given URL, displaying a placeholder 
    /// while loading. Re-requests to a changed URL automatically cancel previous loads.
    func setImage(from url: URL?, placeholder: UIImage? = nil, animated: Bool = true) {
        // Cancel prior task
        if let existingTask = objc_getAssociatedObject(self, &currentTaskKey) as? Task<Void, Never> {
            existingTask.cancel()
        }
        
        self.image = placeholder
        
        guard let url = url else { return }
        
        let urlString = url.absoluteString as NSString
        
        // Check cache
        if let cachedImage = imageCache.object(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // Download
        let task = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Check for cancellation
                try Task.checkCancellation()
                
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: urlString)
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        if animated {
                            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                self.image = image
                            }, completion: nil)
                        } else {
                            self.image = image
                        }
                    }
                }
            } catch {
                // Cancellation or error
            }
        }
        
        objc_setAssociatedObject(self, &currentTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
