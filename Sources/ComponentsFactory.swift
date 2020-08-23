//
//  Created by Dmitry Frishbuter on 18.04.2020
//  Copyright © 2020 Ronas IT. All rights reserved.
//

import UIKit

public protocol ComponentsFactory {
    associatedtype Target: AnyObject
    var target: AnyObject? { get set }

    func makeSections() -> [Section]
}

open class CollectionViewComponentsFactory: ComponentsFactory {
    public typealias Target = UICollectionView
    public var target: AnyObject?

    public var collectionView: UICollectionView? {
        return target as? UICollectionView
    }

    public init() {}

    open func makeSections() -> [Section] {
        return []
    }
}

open class TableViewComponentsFactory: ComponentsFactory {
    public typealias Target = UITableView
    public var target: AnyObject?

    public var tableView: UITableView? {
        return target as? UITableView
    }

    public init() {}

    public func makeSections() -> [Section] {
        return []
    }
}

extension Never: ComponentsFactory {
    public typealias Target = AnyObject

    public var target: AnyObject? {
        get {
            return nil
        }
        set(newValue) {} // swiftlint:disable:this unused_setter_value
    }

    public func makeSections() -> [Section] {
        return []
    }
}
