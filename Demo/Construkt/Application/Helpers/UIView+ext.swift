//
//  👨‍💻 Created by @thatswiftdev on 26/09/25.
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
import SnapKit
import ConstruktKit

// MARK: - Auto-Labelling views for easier debugging constraint
public extension UIView {
    /// Like `.snp.makeConstraints`, but auto-labels all newly installed constraints
    /// with the class name of `self` (e.g., "ProfileHeaderView").
    func snpMakeConstraintsLabeled(_ methodName: String = #function, _ closure: (_ make: ConstraintMaker) -> Void) {
        Self._withAutoLabel(baseView: self, methodName: methodName) { self.snp.makeConstraints(closure) }
    }

    /// Like `.snp.updateConstraints`, labeling any new constraints that get created.
    func snpUpdateConstraintsLabeled(_ methodName: String = #function, _ closure: (_ make: ConstraintMaker) -> Void) {
        Self._withAutoLabel(baseView: self, methodName: methodName) { self.snp.updateConstraints(closure) }
    }

    /// Like `.snp.remakeConstraints`, labeling all recreated constraints.
    func snpRemakeConstraintsLabeled(_ methodName: String = #function, _ closure: (_ make: ConstraintMaker) -> Void) {
        Self._withAutoLabel(baseView: self, methodName: methodName) { self.snp.remakeConstraints(closure) }
    }

    // Core: snapshot → run block → label newly-added constraints on self & ancestors
    private static func _withAutoLabel(baseView: UIView, methodName: String = #function, perform body: () -> Void) {
        let chain = baseView._allSuperviewsIncludingSelf()
        let before = Dictionary(uniqueKeysWithValues: chain.map { ($0, Set($0.constraints)) })

        body()

        let label = String(describing: type(of: baseView)) + "_" + methodName
        chain.forEach { v in
            let pre = before[v] ?? []
            let post = Set(v.constraints)
            let newlyAdded = post.subtracting(pre)
            newlyAdded.forEach { c in
                if (c.identifier ?? "").isEmpty {
                    c.identifier = label
                }
            }
        }
    }

    // Superview chain for where Auto Layout actually installs constraints
    private func _allSuperviewsIncludingSelf() -> [UIView] {
        var result: [UIView] = [self]
        var cur = self.superview
        while let v = cur {
            result.append(v)
            cur = v.superview
        }
        return result
    }
}

// MARK: - UILayoutGuide helpers (optional but handy)

public extension UILayoutGuide {
    func snpMakeConstraintsLabeled(_ closure: (_ make: ConstraintMaker) -> Void) {
        _withAutoLabelForGuide { self.snp.makeConstraints(closure) }
    }
    func snpUpdateConstraintsLabeled(_ closure: (_ make: ConstraintMaker) -> Void) {
        _withAutoLabelForGuide { self.snp.updateConstraints(closure) }
    }
    func snpRemakeConstraintsLabeled(_ closure: (_ make: ConstraintMaker) -> Void) {
        _withAutoLabelForGuide { self.snp.remakeConstraints(closure) }
    }

    private func _withAutoLabelForGuide(run body: () -> Void) {
        // Constraints for guides are installed on the owning view or its ancestors
        guard let owner = self.owningView else { body(); return }
        owner.snpMakeConstraintsLabeled { _ in body() } // reuse the same snapshot/label machinery
    }
}
