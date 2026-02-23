//
//  Builder+Group.swift
//  ViewBuilder
//
//  Created by Michael Long on 7/7/21.
//

import Foundation

/// A semantic grouping construct allowing multiple views to be returned simultaneously when
/// the result builder is structurally limited to returning a single `ViewConvertable`.
struct Group: ViewConvertable {
    
    private var views: [View]
    
    public init(@ViewResultBuilder  _ views: () -> ViewConvertable) {
        self.views = views().asViews()
    }
        
    func asViews() -> [View] {
        views
    }
    
}
