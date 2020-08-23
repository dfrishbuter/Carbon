//
//  Created by Dmitry Frishbuter on 18.04.2020
//  Copyright © 2020 Ronas IT. All rights reserved.
//

public extension Sequence where Element: IdentifiableComponent {

    func buildCells() -> [CellNode] {
        return map { $0.buildCells() }.flatMap { $0 }
    }
}
