import UIKit

// Simple Image Cache to avoid re-downloading
// Simple Image Cache to avoid re-downloading
fileprivate let imageCache: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.countLimit = 100 // Limit to 100 images
    cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB limit
    return cache
}()

public class ImageCache {
    public static func clear() {
        imageCache.removeAllObjects()
        URLCache.shared.removeAllCachedResponses()
    }
}

// Associated object key for storing the current URL
private var currentURLKey: UInt8 = 0

public extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        // Cancel previous task? Ideally yes, but for now let's just tag the view with the URL.
        objc_setAssociatedObject(self, &currentURLKey, url?.absoluteString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let url = url else { return }
        
        let urlString = url.absoluteString as NSString
        
        // Check cache
        if let cachedImage = imageCache.object(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // Download
        Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: urlString)
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        // Verify if the URL is still the same (handle reuse)
                        let currentUrlString = objc_getAssociatedObject(self, &currentURLKey) as? String
                        if currentUrlString == url.absoluteString {
                            self.image = image
                        }
                    }
                }
            } catch {
                print("Failed to load image: \(url)")
            }
        }
    }
}
