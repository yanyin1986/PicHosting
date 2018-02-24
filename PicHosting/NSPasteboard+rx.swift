//
//  PasteboardObserver.swift
//  PicHosting
//
//  Created by Leon.yan on 2018/2/21.
//  Copyright © 2018 Leon.yan. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift

/// obj associated key
private var CachedCountProp = 0

/// interval for scan
private let scanInterval = 0.3
private let scheduler = SerialDispatchQueueScheduler(qos: .background)

extension Reactive where Base: NSPasteboard {

    var cachedCount: Variable<Int> {
        var value = objc_getAssociatedObject(base, &CachedCountProp) as? Variable<Int>
        if value == nil {
            value = Variable(0)
            objc_setAssociatedObject(base, &CachedCountProp, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return value!
    }

    var changeCount: Disposable {
        return Observable<Int>
            .interval(scanInterval, scheduler: scheduler)
            .asDriver(onErrorJustReturn: 0)
            .drive(AnyObserver<Int> { v in
                debugPrint(v.self)
                let value = self.cachedCount
                if value.value != self.base.changeCount {
                    value.value = self.base.changeCount
                }
            })
    }


}
