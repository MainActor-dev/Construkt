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

class CollectionListViewController: UIViewController {
    
    private(set) lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    private(set) lazy var dataSource: CollectionDiffableDataSource = {
        let dataSource = CollectionDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, index, item) in
                return item.cell(in: collectionView, at: index)
            }
        )
        return dataSource
    }()
    
    
    private(set) lazy var refreshControl = UIRefreshControl().then {
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        $0.tintColor = .black
    }
    
    private var adapter: CellControllerAdapter!
    private var onRefresh: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = CellControllerAdapter(dataSource: dataSource)
        configureCollectionView()
    }
    
    @objc private func didPullToRefresh() {
        onRefresh?()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.then {
            $0.dataSource = dataSource
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.clipsToBounds = false
        }
    }
}

// MARK: UICollectionViewDelegate
extension CollectionListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        adapter.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: Behavior Registrations
extension CollectionListViewController {
    func registerPullToRefresh(
        _ tintColor: UIColor = .clear,
        onRefresh: (() -> Void)?
    ) {
        refreshControl.tintColor = tintColor
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        self.onRefresh = onRefresh
    }
    
    func registerLayout(
        handler: @escaping (String) -> NSCollectionLayoutSection?,
        registerDecorationView: ((UICollectionViewCompositionalLayout) -> Void)? = nil
    ) {
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [unowned self] index, _ in
                guard let sect = dataSource.sectionIdentifier(for: index) else { return nil }
                let identifier = sect.identifier.uniqueId
                let layout = handler(identifier)
                
                /// Hide header/footer, decoration, and insets when
                /// there is no data in section.
                if dataSource.snapshot().numberOfItems(inSection: sect) == 0  {
                    layout?.contentInsets = .zero
                    layout?.decorationItems = []
                    layout?.boundarySupplementaryItems = []
                }
                
                return layout
            }
        )
        registerDecorationView?(layout)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func registerHeaderFooter(_ supplementaryViewProvider: CollectionDiffableDataSource.SupplementaryViewProvider?) {
        dataSource.supplementaryViewProvider = supplementaryViewProvider
    }
    
//    func registerPagination(
//        _ scrollView: UIScrollView,
//        model: ListPaginationModel?,
//        handler: ((Int) -> Void)?
//    ) {
//        guard scrollView.isDragging else { return }
//        
//        let offsetY = scrollView.contentOffset.y
//        let scrollHeight = scrollView.contentSize.height - scrollView.frame.height
//        let finalOffsetY = offsetY < 0 ? 0 : offsetY
//        let finalHeight = scrollHeight < 0 ? 0 : scrollHeight
//        
//        guard let model = model,
//              let nextPage = model.nextPage
//        else { return }
//        
//        if (finalOffsetY > finalHeight) && !model.isLastPage && !model.isPaginating {
//            DispatchQueue.main.async { handler?(nextPage) }
//        }
//    }
}
