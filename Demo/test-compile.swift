import UIKit
import ConstruktKit

@ViewBuilder
func testVStack() -> some View {
    VStackView {
        LabelView("A")
    }
}
