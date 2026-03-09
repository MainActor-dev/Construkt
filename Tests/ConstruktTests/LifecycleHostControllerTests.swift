import Testing
import UIKit
@testable import ConstruktKit

@Suite("LifecycleHostControllerTests") @MainActor
struct LifecycleHostControllerTests {

    @Test("onHostDidLoad should be called when host loads view")
    func testOnHostDidLoadIsCalled() {
        var didLoad = false
        
        let view = VStackView { LabelView("Test") }
        .onHostDidLoad {
            didLoad = true
        }
        
        let vc = view.toPresentable() as! LifecycleHostController
        
        // Trigger view load
        _ = vc.view
        
        #expect(didLoad)
    }

    @Test("onHostWillAppear should be called")
    func testOnHostWillAppearIsCalled() {
        var didAppear = false
        
        let view = VStackView { LabelView("Test") }
        .onHostWillAppear { animated in
            didAppear = true
            #expect(animated)
        }
        
        let vc = view.toPresentable() as! LifecycleHostController
        
        // Trigger view load
        _ = vc.view
        vc.viewWillAppear(true)
        
        #expect(didAppear)
    }
}
