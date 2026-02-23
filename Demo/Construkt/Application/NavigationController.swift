import UIKit
import ConstruktKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide standard bar globally
        setNavigationBarHidden(true, animated: false)
        // Enable interactive pop gesture even when bar is hidden
        interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only allow swipe back if there is more than one view controller on the stack
        return viewControllers.count > 1
    }
}
