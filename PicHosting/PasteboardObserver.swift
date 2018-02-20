//
//  PasteboardObserver.swift
//  PicHosting
//
//  Created by Leon.yan on 2018/2/21.
//  Copyright © 2018 Leon.yan. All rights reserved.
//

import Foundation
import Cocoa


protocol PasteboardObserverSubscriber: NSObjectProtocol {

    func pasteboardChanged(_ pasteboard: NSPasteboard)
}

extension PasteboardObserverSubscriber {
    var hashValue: Int { return self.hashValue }
}

enum PasteboardObserverState {
    case disabled
    case enabled
    case paused
}

// TODO: rewrite with RxSwift
class PasteboardObserver: NSObject {
    fileprivate var pasteboard: NSPasteboard = NSPasteboard.general

    fileprivate var subscribers: Set<AnyHashable> = []
    fileprivate var serialQueue: DispatchQueue = DispatchQueue(label: "org.okolodev.PrettyPasteboard", attributes: [])
    fileprivate var changeCount: Int = -1
    fileprivate var state: PasteboardObserverState = PasteboardObserverState.disabled

    override init() {
        super.init()
    }

    deinit {
        self.stopObserving()
        self.removeSubscribers()
    }

    // Observing
    func startObserving() {
        DispatchQueue.global(qos: .default).async {
            self.changeState(PasteboardObserverState.enabled)
            self.observerLoop()
        }
    }

    func stopObserving() {
        self.changeState(PasteboardObserverState.disabled)
    }

    func pauseObserving() {
        self.changeState(PasteboardObserverState.paused)
    }

    func continueObserving() {
        if (self.state == PasteboardObserverState.paused) {
            self.changeCount = self.pasteboard.changeCount;
            self.state = PasteboardObserverState.enabled
        }
    }

    func observerLoop() {
        while self.isEnabled() {
            usleep(250000)
            let countEquals = self.changeCount == self.pasteboard.changeCount
            if countEquals {
                continue
            }

            self.changeCount = self.pasteboard.changeCount
            self.pasteboardContentChanged()
        }
    }

    func pasteboardContentChanged() {
        pauseObserving()

        for anySubscriber in subscribers {
            if let subscriber = anySubscriber as? PasteboardObserverSubscriber {
                subscriber.pasteboardChanged(pasteboard)
            }
        }

        continueObserving()
    }

    func changeState(_ newState: PasteboardObserverState) {
        self.serialQueue.sync {
            self.state = newState
        }
    }

    func isEnabled() -> Bool {
        return self.state == PasteboardObserverState.enabled;
    }

    // Subscribers
    func addSubscriber<T>(_ subscriber: T) where T: PasteboardObserverSubscriber, T: Hashable {
        let (inserted, _) = subscribers.insert(subscriber)
        debugPrint("is inserted? -> \(inserted)")
    }

    func removeSubscribers() {
        subscribers.removeAll()
    }
}
