import Testing
import UIKit
@testable import ConstruktKit

@Suite("Padding")
struct PaddingTests {
    
    @Test("BuilderInternalUIStackView handles padding via layoutMargins")
    func testStackViewPadding() {
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let stack = BuilderInternalUIStackView()
        
        stack.setPadding(insets)
        
        #expect(stack.isLayoutMarginsRelativeArrangement == true)
        #expect(stack.layoutMargins == insets)
    }
    
    @Test("BuilderInternalUILabel handles padding via custom property and drawing")
    func testLabelPadding() {
        let insets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let label = BuilderInternalUILabel()
        
        label.setPadding(insets)
        
        #expect(label.labelMargins == insets)
    }
    
    @Test("Padding modifiers map edge values correctly")
    func testPaddingModifiers() {
        let stack = VStackView {}
            .padding(top: 10, left: 15, bottom: 20, right: 25)
        
        if let internalStack = stack.build() as? BuilderInternalUIStackView {
            #expect(internalStack.layoutMargins == UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 25))
            #expect(internalStack.isLayoutMarginsRelativeArrangement == true)
        } else {
            Issue.record("modifiableView.view is not BuilderInternalUIStackView")
        }
    }
}
