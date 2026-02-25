import UIKit

class Foo {
    func register() {
        let tv = UITextView()
        tv.addAction(UIAction { _ in }, for: .allEditingEvents)
    }
}
