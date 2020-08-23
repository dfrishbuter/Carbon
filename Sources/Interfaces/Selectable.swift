//
//  Created by Dmitry Frishbuter on 17.04.2020
//  Copyright © 2020 Ronas IT. All rights reserved.
//

import UIKit.UICollectionViewCell

public protocol Selectable: class {
    var isSelected: Bool { get set }
}

extension UICollectionViewCell: Selectable {}
