import UIKit

/// The cell as the container that renders the component.
open class UICollectionViewComponentCell: UICollectionViewCell, ComponentRenderable {

    open override var isSelected: Bool {
        didSet {
            if let content = renderedContent as? Selectable {
                content.isSelected = isSelected
            }
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            if let content = renderedContent as? Highlightable {
                content.isHighlighted = isHighlighted
            }
        }
    }

    /// Create a new cell with the frame.
    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func componentDidRender() {}

    // MARK: -  UIResponder

    open override var canBecomeFirstResponder: Bool {
        guard let content = renderedContent as? UIResponder else {
            return super.canBecomeFirstResponder
        }
        return content.canBecomeFirstResponder
    }

    open override var canResignFirstResponder: Bool {
        guard let content = renderedContent as? UIResponder else {
            return super.canResignFirstResponder
        }
        return content.canResignFirstResponder
    }

    open override func becomeFirstResponder() -> Bool {
        guard let content = renderedContent as? UIResponder else {
            return super.becomeFirstResponder()
        }
        return content.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        guard let content = renderedContent as? UIResponder else {
            return super.resignFirstResponder()
        }
        return content.resignFirstResponder()
    }
}
