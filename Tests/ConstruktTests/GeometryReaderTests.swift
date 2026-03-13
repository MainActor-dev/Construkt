import Testing
import UIKit
@testable import ConstruktKit

@Suite("GeometryReader") @MainActor
struct GeometryReaderTests {

    /// Helper: creates a UIWindow, adds the view with explicit size constraints, and triggers layout.
    private func layoutInWindow(_ view: UIView, size: CGSize, origin: CGPoint = .zero) -> UIView {
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 800)))
        
        // translatesAutoresizingMaskIntoConstraints is already false from Modified()
        window.addSubview(view)
        
        // Use constraints to set the exact size (matching how Construkt views are sized)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: size.width),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: origin.x),
            view.topAnchor.constraint(equalTo: window.topAnchor, constant: origin.y),
        ])
        
        window.layoutIfNeeded()
        return window
    }

    // MARK: - Lazy Initialization

    @Test("Has no subviews before being added to hierarchy")
    func testNoSubviewsBeforeHierarchy() {
        let reader = GeometryReader { _ in
            LabelView("Child")
        }.build()

        #expect(reader.subviews.isEmpty)
    }

    // MARK: - Child Embedding

    @Test("Builds and embeds child on didMoveToSuperview")
    func testEmbedsChildOnMoveToSuperview() {
        let reader = GeometryReader { _ in
            LabelView("Child")
        }.build()

        _ = layoutInWindow(reader, size: CGSize(width: 200, height: 300))

        #expect(reader.subviews.count == 1)
        #expect(reader.subviews.first is UILabel)
    }

    // MARK: - GeometryProxy Size

    @Test("GeometryProxy receives correct size")
    func testProxySize() {
        var capturedProxy: GeometryProxy?

        let reader = GeometryReader { proxy in
            capturedProxy = proxy
            return LabelView("Sized")
        }.build()

        _ = layoutInWindow(reader, size: CGSize(width: 320, height: 480))

        #expect(capturedProxy != nil)
        #expect(capturedProxy?.size.width == 320)
        #expect(capturedProxy?.size.height == 480)
    }

    // MARK: - Rebuild on Bounds Change

    @Test("Child view rebuilds when bounds change")
    func testRebuildOnBoundsChange() {
        var buildCount = 0

        let reader = GeometryReader { _ in
            buildCount += 1
            return LabelView("Rebuild \(buildCount)")
        }.build()

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 800))
        window.addSubview(reader)
        
        let widthConstraint = reader.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = reader.heightAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([
            widthConstraint, heightConstraint,
            reader.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            reader.topAnchor.constraint(equalTo: window.topAnchor),
        ])
        window.layoutIfNeeded()

        let firstBuildCount = buildCount
        #expect(firstBuildCount >= 1)

        // Change size via constraints to trigger a rebuild
        widthConstraint.constant = 400
        heightConstraint.constant = 600
        window.layoutIfNeeded()

        #expect(buildCount > firstBuildCount)
    }

    // MARK: - No Rebuild When Size Unchanged

    @Test("No rebuild when size unchanged")
    func testNoRebuildWhenSizeUnchanged() {
        var buildCount = 0

        let reader = GeometryReader { _ in
            buildCount += 1
            return LabelView("Stable")
        }.build()

        _ = layoutInWindow(reader, size: CGSize(width: 200, height: 300))

        let afterFirstLayout = buildCount

        // Trigger layout again without changing size
        reader.setNeedsLayout()
        reader.layoutIfNeeded()

        #expect(buildCount == afterFirstLayout)
    }

    // MARK: - Safe Area Insets

    @Test("GeometryProxy safeAreaInsets are forwarded")
    func testSafeAreaInsets() {
        var capturedProxy: GeometryProxy?

        let reader = GeometryReader { proxy in
            capturedProxy = proxy
            return LabelView("SafeArea")
        }.build()

        _ = layoutInWindow(reader, size: CGSize(width: 200, height: 300))

        // Verify the proxy forwards the actual safe area insets from the view
        #expect(capturedProxy != nil)
        #expect(capturedProxy?.safeAreaInsets == reader.safeAreaInsets)
    }

    // MARK: - Coordinate Conversion

    @Test("GeometryProxy frame(in:) coordinate conversion")
    func testFrameInCoordinateConversion() {
        var capturedProxy: GeometryProxy?

        let reader = GeometryReader { proxy in
            capturedProxy = proxy
            return LabelView("Coords")
        }.build()

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
        let parent = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
        parent.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(parent)
        
        parent.addSubview(reader)
        NSLayoutConstraint.activate([
            reader.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 50),
            reader.topAnchor.constraint(equalTo: parent.topAnchor, constant: 100),
            reader.widthAnchor.constraint(equalToConstant: 200),
            reader.heightAnchor.constraint(equalToConstant: 300),
        ])
        window.layoutIfNeeded()

        #expect(capturedProxy != nil)

        let frameInParent = capturedProxy!.frame(in: parent)
        #expect(frameInParent.origin.x == 50)
        #expect(frameInParent.origin.y == 100)
        #expect(frameInParent.size.width == 200)
        #expect(frameInParent.size.height == 300)
    }

    // MARK: - Standard Modifiers

    @Test("Standard modifiers apply correctly")
    func testStandardModifiers() {
        let reader = GeometryReader { _ in
            LabelView("Modified")
        }
        .backgroundColor(.red)
        .cornerRadius(8)
        .hidden(true)
        .build()

        #expect(reader.backgroundColor == .red)
        #expect(reader.layer.cornerRadius == 8)
        #expect(reader.isHidden == true)
    }

}
