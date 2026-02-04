//
//  CustomNavigationBar.swift
//  Construkt
//
//  Created by User on 2026-02-04.
//

import UIKit

struct CustomNavigationBar: ViewBuilder {
    // Configuration
    var title: String?
    var onBack: (() -> Void)?
    var tintColor: UIColor = .white
    
    // Custom Slots
    var customTitleView: View?
    var trailingViews: [View] = []
    
    // Convenience for Standard Pattern (Back + Title)
    init(title: String? = nil, onBack: (() -> Void)? = nil, tintColor: UIColor = .white) {
        self.title = title
        self.onBack = onBack
        self.tintColor = tintColor
    }
    
    // Convenience for Home Pattern (Custom Title + Trailing Actions)
    init(customTitle: View, trailing: [View] = []) {
        self.customTitleView = customTitle
        self.trailingViews = trailing
        self.tintColor = .white
    }
    
    var body: View {
        var views: [ViewConvertable] = []
        
        // Left: Back Button
        if let onBack {
            let backIcon = HStackView {
                ImageView(UIImage(systemName: "chevron.left"))
                    .tintColor(tintColor)
                    .size(width: 24, height: 24)
                    .contentMode(.scaleAspectFit)
            }
            .onTapGesture { _ in
                onBack()
            }
            .frame(width: 40) // Accessible touch target
            .padding(insets: .init(top: 0, left: 0, bottom: 0, right: 8))
            
            views.append(backIcon)
        }
        
        // Center: Title
        if let customTitleView {
            views.append(customTitleView)
        } else if let title {
            let label = LabelView(title)
                .font(.systemFont(ofSize: 17, weight: .semibold))
                .color(tintColor)
                .alignment(.center)
            views.append(label)
        }
        
        views.append(SpacerView())
        
        // Right: Trailing Actions
        if !trailingViews.isEmpty {
            let trailingStack = HStackView(trailingViews)
                .spacing(16)
                .alignment(.center)
            views.append(trailingStack)
        }
        
        return HStackView(views)
            .alignment(.center)
            .padding(h: 16, v: 8)
            .distribution(.equalCentering)
            .with {
                $0.backgroundColor = .clear 
            }
    }
}

