//
//  👨‍💻 Created by @thatswiftdev on 04/02/26.
//
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
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
//
import UIKit

public enum Skeleton<Cell: UICollectionViewCell> {
    public static func create(
        count: Int = 1,
        identifier: String = UUID().uuidString,
        configure: ((Cell) -> Void)? = nil
    ) -> [CellController] {
        guard count >= 1 else { fatalError("Need at least 1 cell controller") }
        return (1...count).map { idx in
            create(id: identifier + "_SHIMMER_" + String(idx), configure: configure)
        }
    }
    
    public static func create(id: AnyHashable, configure: ((Cell) -> Void)? = nil) -> CellController {
        return CellController(
            id: id,
            model: (),
            registration: CellRegistration<Cell, Void> { cell, indexPath, item in
                configure?(cell)
                cell.layoutIfNeeded()
                cell.setAnimatedSkeletonView(true)
            }
        )
    }
}
