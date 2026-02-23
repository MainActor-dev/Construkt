//
//  👨‍💻 Created by @thatswiftdev on 23/02/26.
//  © 2026, https://github.com/thatswiftdev. All rights reserved.
//
//  Originally created by Michael Long
//  https://github.com/hmlongco/Builder

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

/// A declarative component generating a standard `UITableView`.
///
/// Typically accepts a dynamic list builder (e.g. `DynamicItemViewBuilder`) as its content source.
public struct TableView: ModifiableView {

    public struct CellContext: ViewBuilderContextProvider {
        public var view: UITableViewCell
        public let tableView: UITableView
        public let indexPath: IndexPath
    }

    public let modifiableView = BuilderInternalTableView()
    
    public init() {

    }

    public init(_ builder: AnyIndexableViewBuilder) {
        modifiableView.set(builder)
    }

}

extension ModifiableView where Base: BuilderInternalTableView {

    /// Re-binds the underlying data source builder governing the table view's children dynamically.
    @discardableResult
    public func source(_ builder: AnyIndexableViewBuilder) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.set(builder) }
    }

    /// Sets the style of cell separators.
    @discardableResult
    public func separatorStyle(_ style: UITableViewCell.SeparatorStyle) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.separatorStyle, value: style)
    }

    /// Provides a generic selection handler that automatically resolves the underlying data model
    /// from the `DynamicItemViewBuilder`. This prevents leaking UIKit index paths and table views.
    @discardableResult
    public func onSelect<Item>(_ handler: @escaping (_ item: Item) -> Void) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { view in
            view.selectionHandler = { indexPath in
                if let builder = view.builder as? DynamicItemViewBuilder<Item>, let item = builder.item(at: indexPath.row) {
                    handler(item)
                    return true
                }
                return false
            }
        }
    }

}

open class BuilderInternalTableView: UITableView, UITableViewDataSource, UITableViewDelegate, ViewBuilderEventHandling {
    
    public var updateHandler: ((Any) -> Void)?
    
    public func update(with state: Any) {
        if let handler = updateHandler {
            handler(state)
        } else {
            self.reloadData()
        }
    }
     
    public var builder: AnyIndexableViewBuilder!
    
    /// Internal selection handler intercepting delegate callbacks.
    public var selectionHandler: ((_ indexPath: IndexPath) -> Bool)?
    
    public init() {
        super.init(frame: .zero, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.estimatedRowHeight = 44
        self.rowHeight = UITableView.automaticDimension
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public func set(_ builder: AnyIndexableViewBuilder) {
        self.builder = builder
        builder.updated?
            .observe(on: .main) { [weak self] _ in
                self?.reloadData()
            }
            .store(in: cancelBag)
    }
    
    override public func didMoveToWindow() {
        optionalBuilderAttributes()?.commonDidMoveToWindow(self)
    }

    // delegates
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        builder.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let view = builder.view(at: indexPath.row) else {
            return UITableViewCell(frame: tableView.bounds)
        }
        if let cell = view() as? UITableViewCell {
            return cell
        }
        if let cell = TableViewCell({ view })() as? UITableViewCell {
            return cell
        }
        return UITableViewCell(frame: tableView.bounds)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectionHandler = self.selectionHandler, selectionHandler(indexPath) {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) as? BuilderInternalTableViewCell, let selectionHandler = cell.selectionHandler {
            let context = TableView.CellContext(view: cell, tableView: self, indexPath: indexPath)
            if selectionHandler(context) {
                return
            }
        }
        deselectRow(at: indexPath, animated: true)
    }
    
}

public struct TableViewCell: ModifiableView {
    
    public let modifiableView: BuilderInternalTableViewCell
    
    public init(title: String) {
        modifiableView = BuilderInternalTableViewCell(style: .default, reuseIdentifier: "bTitle")
        modifiableView.textLabel?.text = title
    }

    public init(title: String, subtitle: String) {
        modifiableView = BuilderInternalTableViewCell(style: .subtitle, reuseIdentifier: "bSubtitle")
        modifiableView.textLabel?.text = title
        modifiableView.detailTextLabel?.text = subtitle
    }

    public init(name: String, value: String) {
        modifiableView = BuilderInternalTableViewCell(style: .value1, reuseIdentifier: "bValue1")
        modifiableView.textLabel?.text = name
        modifiableView.detailTextLabel?.text = value
    }

    public init(field: String, value: String) {
        modifiableView = BuilderInternalTableViewCell(style: .value2, reuseIdentifier: "bValue2")
        modifiableView.textLabel?.text = field
        modifiableView.detailTextLabel?.text = value
    }

    public init(_ view: View, padding: UIEdgeInsets? = nil) {
        self.modifiableView = BuilderInternalTableViewCell(frame: .zero)
        let padding = padding ?? UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        modifiableView.contentView.embed(view(), padding: padding)
    }

    public init(padding: UIEdgeInsets? = nil, @ViewResultBuilder _ builder: () -> ViewConvertable) {
        self.modifiableView = BuilderInternalTableViewCell(frame: .zero)
        let padding = padding ?? UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        builder().asViews().forEach { modifiableView.contentView.embed($0, padding: padding) }
    }
    
}

open class BuilderInternalTableViewCell: UITableViewCell {

    public var highlighting = true
    public var selectionHandler: ((_ tableView: TableView.CellContext) -> Bool)?

    private var currentHighlightState: Bool = false

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard highlighting else { return }
        switch (highlighted, currentHighlightState) {
        case (true, false):
            addHighlightOverlay(animated: animated)
        case (false, true):
            removeHighlightOverlay(animated: animated)
        default:
            break // do nothing
        }
        currentHighlightState = highlighted
    }

}

public struct TableViewHeaderFooterView: ModifiableView {

    public let modifiableView = Modified(UITableViewHeaderFooterView()) {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
    }

    public init(@ViewResultBuilder _ builder: () -> [ViewConvertable] ) {
        modifiableView.embed(builder().asViews())
    }

}

extension ModifiableView where Base: BuilderInternalTableViewCell {

    @discardableResult
    public func accessoryType(_ type: UITableViewCell.AccessoryType) -> ViewModifier<Base> {
        ViewModifier(modifiableView, keyPath: \.accessoryType, value: type)
    }

    @discardableResult
    public func onSelect(_ handler: @escaping (_ context: TableView.CellContext) -> Bool) -> ViewModifier<Base> {
        ViewModifier(modifiableView) { $0.selectionHandler = handler }
    }

}
