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

/// A protocol defining a unique identity for a collection view section, used by diffable data sources.
public protocol SectionControllerIdentifier {
    var uniqueId: String { get }
}

extension SectionControllerIdentifier where Self == DefaultSectionIdentifier {
    public static var defaultIdentifier: DefaultSectionIdentifier {
        return DefaultSectionIdentifier()
    }
}

/// Best used when you only have one section and don't care about the `uniqueId`
public struct DefaultSectionIdentifier: SectionControllerIdentifier {
    public let uniqueId: String
    
    public init() {
        self.uniqueId = String(describing: DefaultSectionIdentifier.self)
    }
    
    public init(uniqueId: String) {
        self.uniqueId = uniqueId
    }
}

/// A container that coordinates the components of a single `UICollectionView` section,
/// including its cells, supplementary views (header/footer), and layout definitions.
public struct SectionController {
    
    public typealias Identifier = SectionControllerIdentifier
    
    public let identifier: SectionControllerIdentifier
    public let cells: [CellController]
    public let header: SupplementaryController?
    public let footer: SupplementaryController?
    public var layoutProvider: ((String) -> NSCollectionLayoutSection?)? = nil
    
    public init(
        identifier: SectionControllerIdentifier,
        cells: [CellController],
        header: SupplementaryController? = nil,
        footer: SupplementaryController? = nil,
        layoutProvider: ((String) -> NSCollectionLayoutSection?)? = nil
    ) {
        self.identifier = identifier
        self.cells = cells
        self.header = header
        self.footer = footer
        self.layoutProvider = layoutProvider
    }
}

extension SectionController: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier.uniqueId == rhs.identifier.uniqueId
    }
}

extension SectionController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier.uniqueId)
    }
}

extension [SectionController] {
    public func section(identifier: SectionControllerIdentifier) -> SectionController? {
        return first(where: { $0.identifier.uniqueId == identifier.uniqueId })
    }
    
    public func sectionIndex(identifier: SectionControllerIdentifier) -> Int? {
        return firstIndex(where: { $0.identifier.uniqueId == identifier.uniqueId })
    }
}
