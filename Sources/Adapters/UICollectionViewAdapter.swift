import UIKit

/// An adapter for `UICollectionView`.
/// It can be inherited to implement customized behavior or give some unimplemented
/// methods of delegate or dataSource.
///
/// Attention : In UIKit, if inheriting the @objc class which using generics, the delegate and dataSource
///             are don't work properly, so this class doesn't use generics, and also the class inherited
///             this class shouldn't use generics.
open class UICollectionViewAdapter: NSObject, Adapter {

    public enum CellRegistrationBehavior {
        case `static`(class: (UICollectionViewCell & ComponentRenderable).Type)
        case `dynamic`
    }

    public weak var target: AnyObject?

    public var collectionView: UICollectionView? {
        return target as? UICollectionView
    }

    public var cellRegistrationBehavior: CellRegistrationBehavior = .static(class: UICollectionViewComponentCell.self)

    /// The data to be rendered in the list UI.
    public var data: [Section]

    /// A closure that to handle selection events of cell.
    open var selectionEventHandler: ((EventContext) -> Void)?

    /// Create an adapter with initial data.
    ///
    /// - Parameters:
    ///   - data: An initial data to be rendered.
    public init(data: [Section] = []) {
        self.data = data
    }

    /// Returns a registration info for register each cells.
    ///
    /// - Parameters:
    ///   - collectionView: A collection view to register cell.
    ///   - indexPath: An index path for the cell.
    ///   - node: A node representing cell.
    ///
    /// - Returns: A registration info for each cells.
    open func cellRegistration(collectionView: UICollectionView, indexPath: IndexPath, node: CellNode) -> CellRegistration {
        fatalError("UICollectionViewAdapter uses CellRegistrationBehavior.dynamic, but \(#function) method was not overridden.")
    }

    /// Returns a registration info for register each header views.
    ///
    /// - Parameters:
    ///   - kind: The kind of element for supplementary view.
    ///   - collectionView: A collection view to register supplementary view.
    ///   - indexPath: An index path for the supplementary view.
    ///   - node: A node representing supplementary view.
    ///
    /// - Returns: A registration info for each supplementary views.
    open func supplementaryViewRegistration(forElementKind kind: String,
                                            collectionView: UICollectionView,
                                            indexPath: IndexPath,
                                            node: ViewNode) -> ViewRegistration {
        return ViewRegistration(class: UICollectionComponentReusableView.self)
    }

    /// Returns a node for supplementary view for arbitrary element of kind.
    ///
    /// - Parameters:
    ///   - kind: The kind of element for supplementary view.
    ///   - collectionView: A collection view to display supplementary view.
    ///   - indexPath: An index path for the supplementary view.
    ///   - node: A node representing supplementary view.
    ///
    /// - Returns: A node for supplementary view for arbitrary element of kind.
    open func supplementaryViewNode(forElementKind kind: String, collectionView: UICollectionView, at indexPath: IndexPath) -> ViewNode? {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return headerNode(in: indexPath.section)

        case UICollectionView.elementKindSectionFooter:
            return footerNode(in: indexPath.section)

        default:
            return nil
        }
    }

    /// Returns the kinds of supplementary view registered in the specified collection view.
    ///
    /// - Parameters:
    ///   - collectionView: A collection view that supplementary views registered.
    ///
    /// - Returns: The kinds of supplementary view registered in the specified collection view.
    public func registeredSupplementaryViewKinds(for collectionView: UICollectionView) -> [String] {
        return Array(registeredViewReuseIdentifiersForKindAssociation[collectionView].keys)
    }
}

public extension UICollectionViewAdapter {
    /// Registration info for collection view cell.
    struct CellRegistration {
        /// A class for register cell conforming `ComponentRenderable`.
        public var `class`: (UICollectionViewCell & ComponentRenderable).Type

        /// The nib for register cell.
        public var nib: UINib?

        /// Create a new registration.
        public init(class: (UICollectionViewCell & ComponentRenderable).Type, nib: UINib? = nil) {
            self.class = `class`
            self.nib = nib
        }
    }

    /// Registration info for collection view supplementary view.
    struct ViewRegistration {
        /// A class for register supplementary view conforming `ComponentRenderable`.
        public var `class`: (UICollectionReusableView & ComponentRenderable).Type

        /// The nib for register supplementary view.
        public var nib: UINib?

        /// Create a new registration.
        public init(class: (UICollectionReusableView & ComponentRenderable).Type, nib: UINib? = nil) {
            self.class = `class`
            self.nib = nib
        }
    }

    /// Context when cell is selected.
    struct EventContext {
        /// A collection view of the selected cell.
        public var collectionView: UICollectionView

        /// A node corresponding to the selected cell position.
        public var node: CellNode

        /// The index path of the selected cell.
        public var indexPath: IndexPath

        public init(collectionView: UICollectionView, node: CellNode, indexPath: IndexPath) {
            self.collectionView = collectionView
            self.node = node
            self.indexPath = indexPath
        }
    }
}

extension UICollectionViewAdapter: UICollectionViewDataSource {

    /// Return the number of sections.
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    /// Return the number of items in specified section.
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellNodes(in: section).count
    }

    /// Resister and dequeue the cell at specified index path.
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let node = cellNode(at: indexPath)
        let registration: CellRegistration
        switch cellRegistrationBehavior {
        case .static(let `class`):
            registration = CellRegistration(class: `class`.self)
        case .dynamic:
            registration = cellRegistration(collectionView: collectionView, indexPath: indexPath, node: node)
        }
        let reuseIdentifier = node.component.reuseIdentifier
        let componentCell = collectionView._dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
            ) as? UICollectionViewCell & ComponentRenderable

        guard let cell = componentCell, cell.isMember(of: registration.class) else {
            collectionView.register(cell: registration, forReuseIdentifier: reuseIdentifier)
            return self.collectionView(collectionView, cellForItemAt: indexPath)
        }

        cell.render(component: node.component)

        if collectionView.allowsSelection {
            guard let selectable = node.component.as(Selectable.self) else {
                return cell
            }
            if selectable.isSelected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        }

        return cell
    }

    /// Resister and dequeue the header or footer in specified section.
    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        guard let node = supplementaryViewNode(forElementKind: kind, collectionView: collectionView, at: indexPath) else {
            assertionFailure("Unsupported supplementary element of kind: \(kind). Override `supplementaryViewNode` to adopt this kind.")
            return UICollectionReusableView()
        }

        let registration = supplementaryViewRegistration(forElementKind: kind, collectionView: collectionView, indexPath: indexPath, node: node)
        return dequeueComponentSupplementaryView(
            ofKind: kind,
            collectionView: collectionView,
            indexPath: indexPath,
            node: node,
            registration: registration
        )
    }
}

extension UICollectionViewAdapter: UICollectionViewDelegate {

    /// The event that the cell is about to highlight.
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let node = cellNode(at: indexPath)
        return node.component.shouldHighlight(at: indexPath)
    }

    /// The event that the cell became highlighted.
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let node = cellNode(at: indexPath)
        node.component.didHighlight(at: indexPath)
    }

    /// The event that the cell became unhighlighted.z
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let node = cellNode(at: indexPath)
        node.component.didUnhighlight(at: indexPath)
    }

    /// The event that the cell is about to select.
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let node = cellNode(at: indexPath)
        return node.component.shouldSelect(at: indexPath)
    }

    /// Callback the selected event of cell to the `didSelect` closure.
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = cellNode(at: indexPath)
        node.component.didSelect(at: indexPath)
        guard let selectionEventHandler = selectionEventHandler else {
            return
        }
        let context = EventContext(collectionView: collectionView, node: node, indexPath: indexPath)
        selectionEventHandler(context)
    }

    /// The event that the cell is deselected.
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let node = cellNode(at: indexPath)
        node.component.didDeselect(at: indexPath)
    }

    /// The event that the cell will display in the visible rect.
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ComponentRenderable)?.contentWillDisplay()
    }

    /// The event that the cell did left from the visible rect.
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ComponentRenderable)?.contentDidEndDisplaying()
    }

    /// The event that the header or footer will display in the visible rect.
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplaySupplementaryView view: UICollectionReusableView,
                             forElementKind elementKind: String,
                             at indexPath: IndexPath) {
        (view as? ComponentRenderable)?.contentWillDisplay()
    }

    /// The event that the header or footer did left from the visible rect.
    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplayingSupplementaryView view: UICollectionReusableView,
                             forElementOfKind elementKind: String,
                             at indexPath: IndexPath) {
        (view as? ComponentRenderable)?.contentDidEndDisplaying()
    }
}

private extension UICollectionViewAdapter {

    // swiftlint:disable:next function_parameter_count
    func dequeueComponentSupplementaryView(ofKind kind: String,
                                           collectionView: UICollectionView,
                                           indexPath: IndexPath,
                                           node: ViewNode,
                                           registration: ViewRegistration) -> UICollectionReusableView {
        let reuseIdentifier = node.component.reuseIdentifier
        let componentView = collectionView._dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
            ) as? UICollectionReusableView & ComponentRenderable

        guard let view = componentView, view.isMember(of: registration.class) else {
            collectionView.register(supplementaryView: registration, forSupplementaryViewOfKind: kind, forReuseIdentifier: reuseIdentifier)
            return dequeueComponentSupplementaryView(
                ofKind: kind,
                collectionView: collectionView,
                indexPath: indexPath,
                node: node,
                registration: registration
            )
        }

        view.render(component: node.component)
        return view
    }
}

// swiftlint:disable identifier_name
private let registeredCellReuseIdentifiersAssociation = RuntimeAssociation<Set<String>>(default: [])
private let registeredViewReuseIdentifiersForKindAssociation = RuntimeAssociation<[String: Set<String>]>(default: [:])
// swiftlint:enable identifier_name

private extension UICollectionView {

    func _dequeueReusableCell(withReuseIdentifier reuseIdentifier: String, for indexPath: IndexPath) -> UICollectionViewCell? {
        let registeredCellReuseIdentifiers = registeredCellReuseIdentifiersAssociation[self]

        guard registeredCellReuseIdentifiers.contains(reuseIdentifier) else {
            return nil
        }

        return dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }

    func _dequeueReusableSupplementaryView(ofKind kind: String,
                                           withReuseIdentifier reuseIdentifier: String,
                                           for indexPath: IndexPath) -> UICollectionReusableView? {
        let registeredViewReuseIdentifiersForKind = registeredViewReuseIdentifiersForKindAssociation[self]
        let contains = registeredViewReuseIdentifiersForKind[kind]?.contains(reuseIdentifier) ?? false

        guard contains else {
            return nil
        }

        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
    }

    func register(cell registration: UICollectionViewAdapter.CellRegistration, forReuseIdentifier reuseIdentifier: String) {
        if let nib = registration.nib {
            register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        } else {
            register(registration.class, forCellWithReuseIdentifier: reuseIdentifier)
        }

        registeredCellReuseIdentifiersAssociation[self].insert(reuseIdentifier)
    }

    func register(supplementaryView registration: UICollectionViewAdapter.ViewRegistration,
                  forSupplementaryViewOfKind kind: String,
                  forReuseIdentifier reuseIdentifier: String) {
        if let nib = registration.nib {
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        } else {
            register(registration.class, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        }

        registeredViewReuseIdentifiersForKindAssociation[self][kind, default: []].insert(reuseIdentifier)
    }
}
