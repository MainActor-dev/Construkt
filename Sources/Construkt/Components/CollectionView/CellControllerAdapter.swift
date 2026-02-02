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
import RxSwift
import RxCocoa

private typealias CollectionDelegate = UICollectionViewDelegate & UICollectionViewDataSourcePrefetching

public final class CellControllerAdapter: NSObject, CollectionDelegate {

    private weak var dataSource: CollectionDiffableDataSource?
    
    private let debouncedTapSubject = PublishSubject<IndexPath>()
    private var debounceInterval: TimeInterval = 0.5
    private var disposeBag = DisposeBag()
    
    public init(dataSource: CollectionDiffableDataSource) {
        self.dataSource = dataSource
        super.init()
        setupRxBindings()
    }
    
    private func setupRxBindings() {
        debouncedTapSubject
            .asObservable()
            .debounce(
                .milliseconds(Int(debounceInterval * 1000)),
                scheduler: MainScheduler.instance
            )
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                item(at: indexPath)?.didSelect()
            })
            .disposed(by: disposeBag)
    }

    private func item(at indexPath: IndexPath) -> CellController? {
        dataSource?.itemIdentifier(for: indexPath)
    }

    // MARK: Selection
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debouncedTapSubject.onNext(indexPath)
    }

    // MARK: Prefetch
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.compactMap(item).forEach { $0.prefetch() }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.compactMap(item).forEach { $0.cancelPrefetch() }
    }
}

