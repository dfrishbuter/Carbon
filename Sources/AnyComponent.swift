import UIKit

/// A type-erased component.
public struct AnyComponent: Component {
    @usableFromInline
    internal let box: AnyComponentBox

    /// The value wrapped by this instance.
    @inlinable
    public var base: Any {
        return box.base
    }

    /// A string used to identify a element that is reusable. Default is the type name of `self`.
    @inlinable
    public var reuseIdentifier: String {
        return box.reuseIdentifier
    }

    /// Create a type-erased component that wraps the given instance.
    ///
    /// - Parameters:
    ///   - base: A component to be wrap.
    public init<Base: Component>(_ base: Base) {
        if let anyComponent = base as? AnyComponent {
            self = anyComponent
        } else {
            box = ComponentBox(base)
        }
    }

    /// Returns a new instance of `Content`.
    ///
    /// - Returns: A new `Content` instance for render on top
    ///            of element of list UI element.
    @inlinable
    public func renderContent() -> Any {
        return box.renderContent()
    }

    /// Render properties into the content on the element of list UI.
    ///
    /// - Parameter:
    ///   - content: An instance of `Content` laid out on the element of list UI.
    @inlinable
    public func render(in content: Any) {
        box.render(in: content)
    }

    /// Returns the referencing size of content to render on the list UI.
    ///
    /// - Parameter:
    ///   - bounds: A value of `CGRect` containing the size of the list UI itself,
    ///             such as `UITableView` or `UICollectionView`.
    ///
    /// - Returns: The referencing size of content to render on the list UI.
    ///            If returns nil, the element of list UI falls back to its default size
    ///            like `UITableView.rowHeight` or `UICollectionViewFlowLayout.itemSize`.
    @inlinable
    public func referenceSize(in bounds: CGRect) -> CGSize? {
        return box.referenceSize(in: bounds)
    }

    /// Returns a `Bool` value indicating whether the content should be reloaded.
    ///
    /// - Note: Unlike `Equatable`, this doesn't compare whether the two values
    ///         exactly equal. It's can be ignore property comparisons, if not expect
    ///         to reload content.
    ///
    /// - Parameter:
    ///   - next: The next value to be compared to the receiver.
    ///
    /// - Returns: A `Bool` value indicating whether the content should be reloaded.
    @inlinable
    public func shouldContentUpdate(with next: AnyComponent) -> Bool {
        return box.shouldContentUpdate(with: next.box)
    }

    /// Returns a `Bool` value indicating whether component should be render again.
    ///
    /// - Parameters:
    ///   - next: The next value to be compared to the receiver.
    ///   - content: An instance of content laid out on the element.
    ///
    /// - Returns: A `Bool` value indicating whether the component should be render again.
    @inlinable
    public func shouldRender(next: AnyComponent, in content: Any) -> Bool {
        return box.shouldRender(next: next.box, in: content)
    }

    /// Layout the content on top of element of the list UI.
    ///
    /// - Note: `UIView` and `UIViewController` are laid out with edge constraints by default.
    ///
    /// - Parameters:
    ///   - content: An instance of content to be laid out on top of element.
    ///   - container: A container view to layout content.
    @inlinable
    public func layout(content: Any, in container: UIView) {
        box.layout(content: content, in: container)
    }

    /// The natural size for the passed content.
    ///
    /// - Parameter:
    ///   - content: An instance of content.
    ///
    /// - Returns: A `CGSize` value represents a natural size of the passed content.
    @inlinable
    public func intrinsicContentSize(for content: Any) -> CGSize {
        return box.intrinsicContentSize(for: content)
    }

    /// Invoked every time of before a component got into visible area.
    ///
    /// - Parameter:
    ///   - content: An instance of content getting into display area.
    @inlinable
    public func contentWillDisplay(_ content: Any) {
        box.contentWillDisplay(content)
    }

    /// Invoked every time of after a component went out from visible area.
    ///
    /// - Parameter:
    ///   - content: An instance of content going out from display area.
    @inlinable
    public func contentDidEndDisplaying(_ content: Any) {
        box.contentDidEndDisplaying(content)
    }

    /// Invoked every time when the component is about be highlighted.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    ///
    /// - Returns: A `Bool` value indicating whether the component should be highlighted.
    @inlinable
    public func shouldHighlight(at indexPath: IndexPath) -> Bool {
        return box.shouldHighlight(at: indexPath)
    }

    /// Invoked every time when the component becomes highlighted.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    @inlinable
    public func didHighlight(at indexPath: IndexPath) {
        box.didHighlight(at: indexPath)
    }

    /// Invoked every time when the component becomes unhighlighted.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    @inlinable
    public func didUnhighlight(at indexPath: IndexPath) {
        box.didUnhighlight(at: indexPath)
    }

    /// Invoked every time when the component is about be selected.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    ///
    /// - Returns: A `Bool` value indicating whether the component should be selected.
    @inlinable
    public func shouldSelect(at indexPath: IndexPath) -> Bool {
        return box.shouldSelect(at: indexPath)
    }

    /// Invoked every time when the component becomes selected.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    @inlinable
    public func didSelect(at indexPath: IndexPath) {
        box.didSelect(at: indexPath)
    }

    /// Invoked every time when the component becomes deselected.
    ///
    /// - Parameter:
    ///   - indexPath: Current index path for which the event has been occurred.
    @inlinable
    public func didDeselect(at indexPath: IndexPath) {
        box.didDeselect(at: indexPath)
    }

    /// Returns a base instance casted as given type if possible.
    ///
    /// - Parameter: An expected type of the base instance to casted.
    /// - Returns: A casted base instance.
    @inlinable
    public func `as`<T>(_: T.Type) -> T? {
        return box.base as? T
    }
}

extension AnyComponent: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return "AnyComponent(\(box.base))"
    }
}

@usableFromInline
internal protocol AnyComponentBox {
    var base: Any { get }
    var reuseIdentifier: String { get }

    func renderContent() -> Any
    func render(in content: Any)
    func referenceSize(in bounds: CGRect) -> CGSize?
    func layout(content: Any, in container: UIView)
    func intrinsicContentSize(for content: Any) -> CGSize
    func shouldContentUpdate(with next: AnyComponentBox) -> Bool
    func shouldRender(next: AnyComponentBox, in content: Any) -> Bool

    func contentWillDisplay(_ content: Any)
    func contentDidEndDisplaying(_ content: Any)

    func shouldHighlight(at indexPath: IndexPath) -> Bool
    func didHighlight(at indexPath: IndexPath)
    func didUnhighlight(at indexPath: IndexPath)

    func shouldSelect(at indexPath: IndexPath) -> Bool
    func didSelect(at indexPath: IndexPath)
    func didDeselect(at indexPath: IndexPath)
}

@usableFromInline
internal struct ComponentBox<Base: Component>: AnyComponentBox {
    @usableFromInline
    let baseComponent: Base

    @inlinable
    var base: Any {
        return baseComponent
    }

    @inlinable
    var reuseIdentifier: String {
        return baseComponent.reuseIdentifier
    }

    @usableFromInline
    init(_ base: Base) { // swiftlint:disable:this omitted_parameter_name_in_init
        baseComponent = base
    }

    @inlinable
    func renderContent() -> Any {
        return baseComponent.renderContent()
    }

    @inlinable
    func render(in content: Any) {
        guard let content = content as? Base.Content else {
            return
        }
        baseComponent.render(in: content)
    }

    @inlinable
    func referenceSize(in bounds: CGRect) -> CGSize? {
        return baseComponent.referenceSize(in: bounds)
    }

    @inlinable
    func layout(content: Any, in container: UIView) {
        guard let content = content as? Base.Content else {
            return
        }
        baseComponent.layout(content: content, in: container)
    }

    @inlinable
    func intrinsicContentSize(for content: Any) -> CGSize {
        guard let content = content as? Base.Content else {
            return .zero
        }

        return baseComponent.intrinsicContentSize(for: content)
    }

    @inlinable
    func shouldContentUpdate(with next: AnyComponentBox) -> Bool {
        guard let next = next.base as? Base else {
            return true
        }
        return baseComponent.shouldContentUpdate(with: next)
    }

    @inlinable
    func shouldRender(next: AnyComponentBox, in content: Any) -> Bool {
        guard let next = next.base as? Base, let content = content as? Base.Content else {
            return true
        }
        return baseComponent.shouldRender(next: next, in: content)
    }

    @inlinable
    func contentWillDisplay(_ content: Any) {
        guard let content = content as? Base.Content else {
            return
        }
        baseComponent.contentWillDisplay(content)
    }

    @inlinable
    func contentDidEndDisplaying(_ content: Any) {
        guard let content = content as? Base.Content else {
            return
        }
        baseComponent.contentDidEndDisplaying(content)
    }

    @inlinable
    func shouldHighlight(at indexPath: IndexPath) -> Bool {
        return baseComponent.shouldHighlight(at: indexPath)
    }

    @inlinable
    func didHighlight(at indexPath: IndexPath) {
        baseComponent.didHighlight(at: indexPath)
    }

    @inlinable
    func didUnhighlight(at indexPath: IndexPath) {
        baseComponent.didUnhighlight(at: indexPath)
    }

    @inlinable
    func shouldSelect(at indexPath: IndexPath) -> Bool {
        return baseComponent.shouldSelect(at: indexPath)
    }

    @inlinable
    func didSelect(at indexPath: IndexPath) {
        baseComponent.didSelect(at: indexPath)
    }

    @inlinable
    func didDeselect(at indexPath: IndexPath) {
        baseComponent.didDeselect(at: indexPath)
    }
}
