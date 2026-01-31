//
//  👨‍💻 Created by @thatswiftdev on 02/11/25.
//
//  © 2025, https://github.com/thatswiftdev. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

final class RootViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Construkt"
        view.backgroundColor = .systemBackground
        
        let names = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace"]
        
        view.embed(
            TableView(
                DynamicItemViewBuilder(names) { name in
                    TableViewCell(padding: UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 24)) {
                        LabelView(name)
                            .padding(16)
                            .backgroundColor(.secondarySystemBackground)
                            .cornerRadius(12)
                    }
                }
            )
            .separatorStyle(.none)
        )
    }
}
#if DEBUG
import SwiftUI

struct RootViewController_Preview: SwiftUI.UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RootViewController {
        return RootViewController()
    }
    
    func updateUIViewController(_ uiViewController: RootViewController, context: Context) {}
}

struct RootViewController_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        RootViewController_Preview()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
