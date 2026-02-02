import UIKit
import Factory

// For this demo, we can just treat RootViewController as a simple container or 
// just swap the window root in SceneDelegate (if I had access to it).
// But to keep it simple and within the existing navigation flow:
final class RootViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Immediately push or swap to MoviesViewController
        // Since this is the "Root", we might want it to BE the movie list.
        // But to avoid inheritance mess, let's just embed MoviesViewController as a child
        // or subclass it?
        // Simplest: This IS the navigation controller root.
        
        let moviesVC = MoviesViewController()
        
        // Embed standard child VC pattern
        addChild(moviesVC)
        view.addSubview(moviesVC.view)
        moviesVC.view.frame = view.bounds
        moviesVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        moviesVC.didMove(toParent: self)
        
        title = "Construkt Movies"
    }
}
