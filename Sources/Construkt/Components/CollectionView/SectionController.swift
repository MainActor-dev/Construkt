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

protocol SectionControllerIdentifier {
    var uniqueId: String { get }
}

extension SectionControllerIdentifier where Self == DefaultSectionIdentifier {
    static var defaultIdentifier: DefaultSectionIdentifier {
        return DefaultSectionIdentifier()
    }
}

/// Best used when you only have one section and don't care about the `uniqueId`
struct DefaultSectionIdentifier: SectionControllerIdentifier {
    let uniqueId: String
    
    init() {
        self.uniqueId = String(describing: DefaultSectionIdentifier.self)
    }
}

struct SectionController {
    
    typealias Identifier = SectionControllerIdentifier
    
    let identifier: SectionControllerIdentifier
    let cells: [CellController]
    
    init<ID: Identifier, T, C: UICollectionViewCell>(
        identifier: ID = .defaultIdentifier,
        items: [T],
        state: CellControllerState = .loaded,
        cellConfiguration: ((C, T) -> Void)?,
        didSelect: ((T) -> Void)? = nil
    ) {
        self.identifier = identifier
        switch state {
        case .loaded:
            self.cells = items.map { place in
                return CellController(
                    model: place,
                    registration: CellRegistration<C, T> { cell, _, item in
                        cellConfiguration?(cell, item)
                    },
                    didSelect: didSelect
                )
            }
        case .loading(let total):
            self.cells = Skeleton<C>.create(
                count: total,
                identifier: identifier.uniqueId
            )
        }
    }
}

extension SectionController: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier.uniqueId == rhs.identifier.uniqueId
    }
}

extension SectionController: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier.uniqueId)
    }
}

extension [SectionController] {
    func section(identifier: SectionControllerIdentifier) -> SectionController? {
        return first(where: { $0.identifier.uniqueId == identifier.uniqueId })
    }
    
    func sectionIndex(identifier: SectionControllerIdentifier) -> Int? {
        return firstIndex(where: { $0.identifier.uniqueId == identifier.uniqueId })
    }
}
