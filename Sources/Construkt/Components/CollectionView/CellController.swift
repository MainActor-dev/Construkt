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

enum CellControllerState: Equatable {
    typealias TotalSkeleton = Int
    case loading(TotalSkeleton)
    case loaded
}

struct CellController: Hashable {
    
    private let id: AnyHashable
    private let makeCell: (UICollectionView, IndexPath) -> UICollectionViewCell
    private let onSelect: (() -> Void)?
    private let onPrefetch: (() -> Void)?
    private let onCancelPrefetch: (() -> Void)?

    init<Cell: UICollectionViewCell, Model>(
        id: AnyHashable = UUID(),
        model: Model,
        registration: UICollectionView.CellRegistration<Cell, Model>,
        didSelect: ((Model) -> Void)? = nil,
        prefetch: ((Model) -> Void)? = nil,
        cancelPrefetch: ((Model) -> Void)? = nil
    ) {
        self.id = id
        self.makeCell = { collectionView, indexPath in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: model
            )
        }
        self.onSelect = didSelect.map {
            handler in { handler(model) }
        }
        self.onPrefetch = prefetch.map {
            handler in { handler(model) }
        }
        self.onCancelPrefetch = cancelPrefetch.map {
            handler in { handler(model) }
        }
    }

    static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func cell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        makeCell(collectionView, indexPath)
    }

    func didSelect() {
        onSelect?()
    }

    func prefetch() {
        onPrefetch?()
    }

    func cancelPrefetch() {
        onCancelPrefetch?()
    }
}
