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

public extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_ cell: Cell.Type) {
        let identifier = String(describing: cell)
        register(cell, forCellWithReuseIdentifier: identifier)
    }
    
    func registerHeader<ReusableView: UICollectionReusableView>(_ reusableView: ReusableView.Type) {
        let identifier = String(describing: reusableView)
        register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    func registerFooter<ReusableView: UICollectionReusableView>(_ reusableView: ReusableView.Type) {
        let identifier = String(describing: reusableView)
        register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(at indexPath: IndexPath) -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
    }
    
    func dequeueReusableHeader<Header: UICollectionReusableView>(at indexPath: IndexPath) -> Header {
        let identifier = String(describing: Header.self)
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as! Header
    }
    
    func dequeueReusableFooter<Footer: UICollectionReusableView>(at indexPath: IndexPath) -> Footer {
        let identifier = String(describing: Footer.self)
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as! Footer
    }
}
