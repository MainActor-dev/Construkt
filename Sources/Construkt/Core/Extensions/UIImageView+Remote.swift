import UIKit

// Simple Image Cache to avoid re-downloading
fileprivate let imageCache = NSCache<NSString, UIImage>()

public extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        guard let url = url else { return }
        
        // Check cache
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        // Download
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                print("Failed to load image: \(url)")
            }
        }
    }
}
