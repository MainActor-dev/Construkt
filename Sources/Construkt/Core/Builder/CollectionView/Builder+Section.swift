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

// MARK: - Protocols

/// A protocol that identifies types capable of resolving into a reactive binding of `SectionController` arrays.
public protocol SectionObservable {
    /// Converts the conforming type into a binding of section controllers.
    func asSectionObservable() -> AnyViewBinding<[SectionController]>
}

extension SectionController: SectionObservable {
    public func asSectionObservable() -> AnyViewBinding<[SectionController]> { .just([self]) }
}

extension Array: SectionObservable where Element == SectionController {
    public func asSectionObservable() -> AnyViewBinding<[SectionController]> { .just(self) }
}

/// A marker protocol identifying valid declarative components belonging within a `Section` body.
public protocol SectionComponent {}

extension Array: SectionComponent where Element == CellController {}

// MARK: - Section Constructs

/// A declarative wrapper defining a supplementary header view for a `Section`.
public struct Header: SectionComponent {
    public let controller: SupplementaryController
    
    /// Initializes the header with a unique ID and a statically structured declarative `View` block.
    public init(id: AnyHashable? = nil, @ViewResultBuilder content: @escaping () -> ViewConvertable) {
        self.controller = SupplementaryController(
            id: id ?? AnyHashable(UUID()),
            elementKind: UICollectionView.elementKindSectionHeader,
            viewType: HostingReusableView<VStackView>.self
        ) { view in
            view.setAnimatedSkeletonView(false)
            let views = content().asViews()
            view.host(VStackView(views))
        }
    }
    
    // Internal init for modifier
    private init(_ controller: SupplementaryController) {
        self.controller = controller
    }
    
    /// Imperatively hides or shows the header.
    public func hidden(_ isHidden: Bool) -> Header {
        var copy = self.controller
        copy.isHidden = isHidden
        return Header(copy)
    }
}

/// A declarative wrapper defining a supplementary footer view for a `Section`.
public struct Footer: SectionComponent {
    public let controller: SupplementaryController
    
    /// Initializes the footer with a unique ID and a statically structured declarative `View` block.
    public init(id: AnyHashable? = nil, @ViewResultBuilder content: @escaping () -> ViewConvertable) {
        self.controller = SupplementaryController(
            id: id ?? AnyHashable(UUID()),
            elementKind: UICollectionView.elementKindSectionFooter,
            viewType: HostingReusableView<VStackView>.self
        ) { view in
            view.setAnimatedSkeletonView(false)
            let views = content().asViews()
            view.host(VStackView(views))
        }
    }
    
    // Internal init for modifier
    private init(_ controller: SupplementaryController) {
        self.controller = controller
    }
    
    /// Imperatively hides or shows the footer.
    public func hidden(_ isHidden: Bool) -> Footer {
        var copy = self.controller
        copy.isHidden = isHidden
        return Footer(copy)
    }
}

// Ensure CellController conforms to SectionComponent (via CellConvertible wrapper)
public struct CellComponent: SectionComponent {
    let cells: [CellController]
}

extension CellController: SectionComponent {}

// MARK: - Section Content Builder

/// An intermediate structure aggregating parsed cells, headers, and footers from a single `SectionContentBuilder`.
public struct SectionContent {
    var cells: [CellController] = []
    var header: SupplementaryController?
    var footer: SupplementaryController?
}

/// A result builder designed to aggregate headers, footers, and cells into a unified `SectionContent` model.
@resultBuilder
public struct SectionContentBuilder {
    public static func buildBlock(_ components: SectionComponent...) -> SectionContent {
        var content = SectionContent()
        for component in components {
            if let header = component as? Header {
                content.header = header.controller
            } else if let footer = component as? Footer {
                content.footer = footer.controller
            } else if let cell = component as? CellController {
                content.cells.append(cell)
            } else if let cellConvertible = component as? CellConvertible {
                content.cells.append(contentsOf: cellConvertible.asCells())
            }
        }
        return content
    }
    
    public static func buildExpression(_ expression: CellConvertible) -> SectionComponent {
        return expression
    }
    
    public static func buildExpression(_ expression: Header) -> SectionComponent {
        return expression
    }
    
    public static func buildExpression(_ expression: Footer) -> SectionComponent {
        return expression
    }
    
    public static func buildOptional(_ component: SectionComponent?) -> SectionComponent {
         return component ?? CellComponent(cells: [])
    }
    
    public static func buildEither(first: SectionComponent) -> SectionComponent {
        return first
    }

    public static func buildEither(second: SectionComponent) -> SectionComponent {
        return second
    }
    
    public static func buildArray(_ components: [SectionComponent]) -> SectionComponent {
        // Flatten cells
        var cells: [CellController] = []
        components.forEach {
            if let cell = $0 as? CellController {
                cells.append(cell)
            } else if let convertible = $0 as? CellConvertible {
                cells.append(contentsOf: convertible.asCells())
            }
        }
        return CellComponent(cells: cells)
    }
}

// MARK: - Section Result Builder
/// A robust result builder mapping discrete `Section` definitions into unified binding-powered observables.
@resultBuilder
public struct SectionResultBuilder {
    public static func buildBlock() -> AnyViewBinding<[SectionController]> {
        .just([])
    }
    
    public static func buildBlock(_ components: SectionObservable...) -> AnyViewBinding<[SectionController]> {
        let bindings = components.map { $0.asSectionObservable() }
        return combineLatestBindings(bindings)
    }
    
    public static func buildIf(_ value: SectionObservable?) -> AnyViewBinding<[SectionController]> {
        value?.asSectionObservable() ?? .just([])
    }
    
    public static func buildEither(first: SectionObservable) -> AnyViewBinding<[SectionController]> {
        first.asSectionObservable()
    }
    
    public static func buildEither(second: SectionObservable) -> AnyViewBinding<[SectionController]> {
        second.asSectionObservable()
    }
    
    public static func buildArray(_ components: [SectionObservable]) -> AnyViewBinding<[SectionController]> {
        let bindings = components.map { $0.asSectionObservable() }
        return combineLatestBindings(bindings)
    }
}


// MARK: - Section
/// A declarative constructor for generating a `SectionController` via native data bindings 
/// or static `CellResultBuilder` closures.
public struct Section: SectionObservable {
    private let binding: AnyViewBinding<[SectionController]>
    
    // MARK: Initializers
    
    /// Standard initializer with a builder block (Static)
    public init(
        id: SectionControllerIdentifier,
        @CellResultBuilder content: () -> [CellController]
    ) {
        let cells = content()
        let section = SectionController(identifier: id, cells: cells, layoutProvider: nil)
        self.binding = .just([section])
    }
    
    /// Static Data-binding initializer
    public init<T>(
        id: SectionControllerIdentifier,
        items: [T],
        @CellResultBuilder content: (T) -> [CellController]
    ) {
        let cells = items.flatMap { content($0) }
        let section = SectionController(identifier: id, cells: cells, header: nil, footer: nil, layoutProvider: nil)
        self.binding = .just([section])
    }
    
    /// Reactive Binding initializer
    public init<B: ViewBinding>(
        id: SectionControllerIdentifier,
        binding: B,
        @CellResultBuilder content: @escaping (B.Value) -> [CellController]
    ) {
        self.binding = binding
            .map { items in
                return [SectionController(identifier: id, cells: content(items), header: nil, footer: nil, layoutProvider: nil)]
            }
    }
    
    /// Reactive Binding with element iteration helper
    public init<B: ViewBinding, Element>(
        id: SectionControllerIdentifier,
        items binding: B,
        header: Header? = nil,
        footer: Footer? = nil,
        @CellResultBuilder content: @escaping (Element) -> [CellController]
    ) where B.Value == [Element] {
        self.binding = binding
            .map { items in
                let cells = items.flatMap { content($0) }
                return [
                    SectionController(
                        identifier: id,
                        cells: cells,
                        header: header?.controller,
                        footer: footer?.controller,
                        layoutProvider: nil
                    )
                ]
            }
    }

    // MARK: - Actions Modifier
    
    /// Attaches a type-safe selection action that applies uniformly to every item housed dynamically within this section.
    public func onSelect<T>(_ handler: @escaping (T) -> Void) -> Section {
        let improved = binding.map { sections in
            sections.map { section in
                let newCells = section.cells.map { cell in
                    var modelToUse = cell.model
                    
                    if let wrapper = modelToUse as? CellContentWrapper {
                        modelToUse = wrapper.originalModel
                    }
                    
                    guard let model = modelToUse as? T else { return cell }
                    
                    return cell.withSelection {
                        handler(model)
                    }
                }
                 
                return SectionController(
                    identifier: section.identifier,
                    cells: newCells,
                    header: section.header,
                    footer: section.footer,
                    layoutProvider: section.layoutProvider
                )
            }
        }
        return Section(binding: improved)
    }
    
    /// Binds an externally injected target reference weakly into every item's tap action dynamically inside this section.
    public func onSelect<T, Target: AnyObject>(on target: Target, _ handler: @escaping (Target, T) -> Void) -> Section {
        let improved = binding
            .map { [weak target] sections in
                guard let target = target else { return sections }
            
                return sections.map { section in
                    let newCells = section.cells.map { cell in
                        var modelToUse = cell.model
                        
                        if let wrapper = modelToUse as? CellContentWrapper {
                            modelToUse = wrapper.originalModel
                        }
                        
                        guard let model = modelToUse as? T else { return cell }
                        return cell.withSelection { [weak target] in
                            guard let target = target else { return }
                            handler(target, model)
                        }
                    }
                     
                    return SectionController(
                        identifier: section.identifier,
                        cells: newCells,
                        header: section.header,
                        footer: section.footer,
                        layoutProvider: section.layoutProvider
                    )
                }
        }
        return Section(binding: improved)
    }

    /// Builder Initializer with Header/Footer support
    public init(
        id: SectionControllerIdentifier,
        @SectionContentBuilder content: () -> SectionContent
    ) {
        let sectionContent = content()
        let section = SectionController(
            identifier: id, 
            cells: sectionContent.cells, 
            header: sectionContent.header, 
            footer: sectionContent.footer, 
            layoutProvider: nil
        )
        self.binding = .just([section])
    }
    
    // MARK: Modifiers
    /// Uses a standard closure returning an optional `NSCollectionLayoutSection`, parameterized by environment.
    public func layout(_ handler: @escaping (String) -> NSCollectionLayoutSection?) -> Section {
        let improved = binding.map { sections in
            sections.map { section in
                var copy = section
                copy.layoutProvider = handler
                return copy
            }
        }
        return Section(binding: improved)
    }
    
    /// Uses a declarative `@LayoutBuilder` closure to synthesize the UI layout for this specific section implicitly.
    public func layout(@LayoutBuilder _ builder: @escaping () -> NSCollectionLayoutSection) -> Section {
        let improved = binding.map { sections in
            sections.map { section in
                var copy = section
                copy.layoutProvider = { _ in builder() }
                return copy
            }
        }
        return Section(binding: improved)
    }
    
    /// Uses a declarative `@LayoutBuilder` closure dynamically injected with an environment string identifier.
    public func layout(@LayoutBuilder _ builder: @escaping (String) -> NSCollectionLayoutSection) -> Section {
        let improved = binding.map { sections in
            sections.map { section in
                var copy = section
                copy.layoutProvider = builder
                return copy
            }
        }
        return Section(binding: improved)
    }
    
    /// Modifies the structural definition of the section's header by providing an internally injected declarative `Header` block.
    public func header(_ handler: @escaping () -> Header) -> Section {
        let improved = binding.map { sections in
            sections.map { section in
                return SectionController(
                    identifier: section.identifier,
                    cells: section.cells,
                    header: handler().controller,
                    footer: section.footer,
                    layoutProvider: section.layoutProvider
                )
            }
        }
        return Section(binding: improved)
    }
    
    /// Modifies the structural definition of the section's footer by providing an internally injected declarative `Footer` block.
    public func footer(_ handler: @escaping () -> Footer) -> Section {
        let improved = binding.map { sections in
             sections.map { section in
                 return SectionController(
                     identifier: section.identifier,
                     cells: section.cells,
                     header: section.header,
                     footer: handler().controller,
                     layoutProvider: section.layoutProvider
                 )
             }
         }
         return Section(binding: improved)
     }
    
    /// Imposes an automated animated "Skeleton mode" replacing layout components with shimmer placeholder items.
    /// Dictated dynamically by resolving a binding boolean argument `when:`.
    public func skeleton<C, B>(
        _ type: C.Type,
        count: Int,
        when skeletonBinding: B,
        includeSuppmentary: Bool = false,
        hideSupplementary: Bool = false,
        configure: ((C) -> Void)? = nil
    ) -> Section where C: UICollectionViewCell, B: ViewBinding, B.Value == Bool {
        
        let combined = AnyViewBinding<([SectionController], Bool)>.combineLatest(binding, skeletonBinding)
            .map { (sections, isLoading) -> [SectionController] in
                if isLoading {
                    return sections.map { section in
                         var header = hideSupplementary ? nil : section.header
                         if includeSuppmentary { header = header?.asSkeleton() }
                         
                         var footer = hideSupplementary ? nil : section.footer
                         if includeSuppmentary { footer = footer?.asSkeleton() }
                         
                         return SectionController(
                            identifier: section.identifier,
                            cells: Skeleton<C>.create(count: count, configure: configure),
                            header: header,
                            footer: footer,
                            layoutProvider: section.layoutProvider
                         )
                    }
                } else {
                    return sections
                }
            }
            
        return Section(binding: combined)
    }
    
    /// Imposes an automated declarative "Skeleton mode" loading block via `HostingCell` replacing the current section layout.
    public func skeleton<Content: View, B: ViewBinding>(
        count: Int,
        when binding: B,
        includeSupplementary: Bool = false,
        hideSupplementary: Bool = false,
        placeholder: @escaping () -> Content
    ) -> Section where B.Value == Bool {
        return skeleton(
            HostingCell<Content>.self,
            count: count,
            when: binding,
            includeSuppmentary: includeSupplementary,
            hideSupplementary: hideSupplementary
        ) { cell in
            cell.host(placeholder())
        }
    }
    
    /// Submits a distinct declarative nested view substituting this entire section context if the 
    /// dynamically resolved properties within evaluate functionally completely empty or to length 0 count.
    public func emptyState(
        layout: ((String) -> NSCollectionLayoutSection)? = nil,
        @ViewResultBuilder _ content: @escaping () -> ViewConvertable
    ) -> Section {
        return Section(binding: binding.map { sections in
            sections.map { section in
                if section.cells.isEmpty {
                    // Create Empty Cell
                    let emptyCell = CellController(
                        id: "empty_\(section.identifier.uniqueId)",
                        model: (),
                        registration: UICollectionView.CellRegistration<HostingCell<UIView>, Void> { cell, _, _ in
                            let views = content().asViews()
                            let stack = VStackView(views)
                                .alignment(.center)
                            cell.host(stack.build())
                        },
                        didSelect: nil
                    )
                    
                    // Determine Layout
                    let layoutProvider: (String) -> NSCollectionLayoutSection? = { env in
                        return Section.makeEmptyStateLayout(
                            env: env,
                            customLayout: layout,
                            section: section
                        )
                    }
                    
                    return SectionController(
                        identifier: section.identifier,
                        cells: [emptyCell],
                        header: section.header,
                        footer: section.footer,
                        layoutProvider: layoutProvider
                    )
                }
                return section
            }
        })
    }
    
    // MARK: - Helpers
    
    private static func makeEmptyStateLayout(
        env: String,
        customLayout: ((String) -> NSCollectionLayoutSection)?,
        section: SectionController
    ) -> NSCollectionLayoutSection? {
        let sectionLayout: NSCollectionLayoutSection
        if let customLayout = customLayout {
            sectionLayout = customLayout(env)
        } else {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            sectionLayout = NSCollectionLayoutSection(group: group)
        }
        
        if let originalProvider = section.layoutProvider, let originalLayout = originalProvider(env) {
            var supplementaries = sectionLayout.boundarySupplementaryItems
            
            supplementaries.removeAll { $0.elementKind == UICollectionView.elementKindSectionHeader }
            supplementaries.removeAll { $0.elementKind == UICollectionView.elementKindSectionFooter }
            
            let originalSupplementaries = originalLayout.boundarySupplementaryItems.filter {
                $0.elementKind == UICollectionView.elementKindSectionHeader ||
                $0.elementKind == UICollectionView.elementKindSectionFooter
            }
            supplementaries.append(contentsOf: originalSupplementaries)
            
            sectionLayout.boundarySupplementaryItems = supplementaries
            sectionLayout.contentInsets = originalLayout.contentInsets
        } else {
             addStartSupplementaries(to: sectionLayout, from: section)
        }
        
        return sectionLayout
    }
    
    private static func addStartSupplementaries(to layout: NSCollectionLayoutSection, from section: SectionController) {
         var supplementaries = layout.boundarySupplementaryItems
         let hasHeader = supplementaries.contains { $0.elementKind == UICollectionView.elementKindSectionHeader }
         let hasFooter = supplementaries.contains { $0.elementKind == UICollectionView.elementKindSectionFooter }
         
         if !hasHeader, let _ = section.header {
             let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
             let header = NSCollectionLayoutBoundarySupplementaryItem(
                 layoutSize: headerSize,
                 elementKind: UICollectionView.elementKindSectionHeader,
                 alignment: .top
             )
             supplementaries.append(header)
         }
         
         if !hasFooter, let _ = section.footer {
              let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
              let footer = NSCollectionLayoutBoundarySupplementaryItem(
                  layoutSize: footerSize,
                  elementKind: UICollectionView.elementKindSectionFooter,
                  alignment: .bottom
              )
              supplementaries.append(footer)
         }
         layout.boundarySupplementaryItems = supplementaries
    }
    
    // Internal init for modifiers
    private init(binding: AnyViewBinding<[SectionController]>) {
        self.binding = binding
    }

    // MARK: Convert
    
    public func asSectionObservable() -> AnyViewBinding<[SectionController]> {
        return binding
    }
}
