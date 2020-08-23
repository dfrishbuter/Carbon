//
//  Created by Dmitry Frishbuter on 14.04.2020
//  Copyright © 2020 Ronas IT. All rights reserved.
//

import UIKit.UICollectionViewCell

public protocol Highlightable: class {
    var isHighlighted: Bool { get set }
}

extension UICollectionViewCell: Highlightable {}
