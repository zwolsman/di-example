//
// Created by Marvin Zwolsman on 22/12/2021.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
            to keyPath: ReferenceWritableKeyPath<T, Output>,
            on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
