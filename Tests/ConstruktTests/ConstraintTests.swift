import Testing
import UIKit
@testable import ConstruktKit

@Suite("Constraints")
struct ConstraintTests {
    
    @Test("frame(height:width:) applies exact constraints")
    func testFrameConstraints() {
        let view = UIView()
        view.frame(height: 100, width: 200)
        
        let constraints = view.constraints
        #expect(constraints.count == 2)
        
        if let heightConstraint = constraints.first(where: { $0.firstAttribute == .height }) {
            #expect(heightConstraint.constant == 100)
            #expect(heightConstraint.priority == UILayoutPriority(999))
            #expect(heightConstraint.relation == .equal)
        } else {
            Issue.record("Height constraint not found")
        }
        
        if let widthConstraint = constraints.first(where: { $0.firstAttribute == .width }) {
            #expect(widthConstraint.constant == 200)
            #expect(widthConstraint.priority == UILayoutPriority(999))
            #expect(widthConstraint.relation == .equal)
        } else {
            Issue.record("Width constraint not found")
        }
    }
    
    @Test("height(min:) applies greaterThanOrEqual constraint")
    func testHeightMin() {
        let view = UIView()
        view.height(min: 50, priority: .defaultHigh)
        
        let constraints = view.constraints
        #expect(constraints.count == 1)
        
        if let heightConstraint = constraints.first {
            #expect(heightConstraint.firstAttribute == .height)
            #expect(heightConstraint.constant == 50)
            #expect(heightConstraint.relation == .greaterThanOrEqual)
            #expect(heightConstraint.priority == .defaultHigh)
            #expect(heightConstraint.identifier == "minheight")
        }
    }
    
    @Test("width(max:) applies lessThanOrEqual constraint")
    func testWidthMax() {
        let view = UIView()
        view.width(max: 300, priority: .defaultLow)
        
        let constraints = view.constraints
        #expect(constraints.count == 1)
        
        if let widthConstraint = constraints.first {
            #expect(widthConstraint.firstAttribute == .width)
            #expect(widthConstraint.constant == 300)
            #expect(widthConstraint.relation == .lessThanOrEqual)
            #expect(widthConstraint.priority == .defaultLow)
            #expect(widthConstraint.identifier == "maxwidth")
        }
    }
    
    @Test("compression resistance and hugging priority setup")
    func testPriorities() {
        let view = UIView()
        view.contentCompressionResistancePriority(.required, for: .horizontal)
        view.contentHuggingPriority(.defaultHigh, for: .vertical)
        
        #expect(view.contentCompressionResistancePriority(for: .horizontal) == .required)
        #expect(view.contentHuggingPriority(for: .vertical) == .defaultHigh)
    }
    
    @Test("zIndex sets layer position")
    func testZIndex() {
        let view = UIView()
        view.zIndex(5)
        
        #expect(view.layer.zPosition == 5)
    }
}
