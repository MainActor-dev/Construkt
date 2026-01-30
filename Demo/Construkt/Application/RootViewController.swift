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
        
        view.embed(
            VStackView {
                SpacerView()
                
                LabelView("Welcome to Construkt")
                    .font(.largeTitle)
                    .color(.label)
                    .alignment(.center)
                
                LabelView("The declarative UIKit library for modern iOS apps.")
                    .font(.body)
                    .color(.secondaryLabel)
                    .alignment(.center)
                    .numberOfLines(0)
                
                SpacerView(40)
                
                ButtonView("Get Started") { _ in
                    print("🚀 Journey Started!")
                }
                .backgroundColor(.systemBlue, for: .normal)
                .color(.white, for: .normal)
                .cornerRadius(12)
                .padding(h: 32, v: 12)
                
                SpacerView()
            }
            .spacing(16)
            .padding(24)
            .alignment(.center)
        )
    }
}
