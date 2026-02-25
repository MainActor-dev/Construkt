//
//  ComponentsTestViewController.swift
//  Construkt
//

import UIKit
import ConstruktKit

class ComponentsTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Component Tester"
        
        let headerView = UILabel().with {
            $0.text = "Component Tester"
            $0.font = .systemFont(ofSize: 28, weight: .bold)
            $0.textColor = .white
        }
        
        // 1. Blur & Vibrancy & Gradient
        let blurView = ZStackView {
            BlurView(style: .dark)
                .vibrancy(UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))) {
                    UILabel().with {
                        $0.text = "Vibrant Blur Text"
                        $0.font = .systemFont(ofSize: 24, weight: .bold)
                        $0.textAlignment = .center
                        $0.textColor = .white
                    }
                }
            
            LinearGradient(
                colors: [UIColor.clear, UIColor.red],
                startPoint: CGPoint(x: 0.5, y: 0.0),
                endPoint: CGPoint(x: 0.5, y: 1.0)
            )
        }
        .frame(height: 200)
        .cornerRadius(16)
        
        // 2. Toggle
        let toggleView = HStackView {
            UILabel().with { $0.text = "Status"; $0.textColor = .white }
            SpacerView()
            Toggle(isOn: true)
                .onTintColor(.systemGreen)
        }
        .alignment(.center)
        
        // 3. Slider
        let sliderView = VStackView(spacing: 8) {
            HStackView {
                UILabel().with { $0.text = "Volume:"; $0.textColor = .lightGray }
                SpacerView()
                UILabel().with { $0.text = "Static Volume"; $0.textColor = .white }
            }
            Slider(value: 0.5, in: 0.0...1.0)
                .thumbTintColor(.systemBlue)
                .minimumTrackTintColor(.systemBlue)
        }
        
        // 4. ProgressView
        let progressSection = VStackView(spacing: 8) {
            UILabel().with { $0.text = "Loading Progress:"; $0.textColor = .lightGray }
            ProgressView(value: 0.65)
                .progressTintColor(.systemPurple)
        }
        
        // 5. Stepper
        let stepperView = HStackView {
            UILabel().with { $0.text = "Items to buy:"; $0.textColor = .white }
            SpacerView()
            Stepper(value: 1.0, in: 1...10, step: 1)
        }
        .alignment(.center)
        
        // 6. TextEditor
        let textEditorView = VStackView(spacing: 8) {
            UILabel().with { $0.text = "Notes:"; $0.textColor = .lightGray }
            TextEditor(text: "Type here...")
                .backgroundColor(UIColor.darkGray.withAlphaComponent(0.3))
                .frame(height: 120)
                .cornerRadius(8)
        }
        
        view.embed(
        VerticalScrollView {
            VStackView(spacing: 24) {
                headerView
                blurView
                toggleView
                sliderView
                progressSection
                stepperView
                textEditorView
            }
            .padding(24)
        }
        )
    }
}
