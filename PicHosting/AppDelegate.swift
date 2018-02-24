//
//  AppDelegate.swift
//  PicHosting
//
//  Created by Leon.yan on 2018/2/21.
//  Copyright © 2018 Leon.yan. All rights reserved.
//

import Cocoa
import Carbon
import RxSwift
import RxCocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    fileprivate let disposeBag = DisposeBag()
    fileprivate var enable: Variable<Bool> = Variable(true)
    fileprivate var changeCount: Disposable?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerHotKeys()
        initApp()

        enable.asObservable()
            .bind { (e) in
                if e {
                    NSPasteboard.general.rx.cachedCount
                        .asObservable()
                        .subscribe({ (v) in
                            debugPrint("vv --> \(v)")
                        })
                        .disposed(by: self.disposeBag)
                    self.changeCount = NSPasteboard.general.rx.changeCount
                } else {
                    debugPrint("set -> no")
                    self.changeCount?.dispose()
                    self.changeCount = nil
                }
        }.disposed(by: disposeBag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.enable.value = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
            self.enable.value = true
        })
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


extension AppDelegate {

    func initApp()  {

//        switch AppCache.shared.appConfig.linkType {
//        case .markdown:
//            MarkdownItem.state = NSControl.StateValue.off // .init(1)
//        //            MarkdownItem.state = 1
//        case .url:
//            MarkdownItem.state = NSControl.StateValue.on
//        }

//        let a = NSPasteboard.general.rx.observe(KVORepresentable.Protocol, <#T##keyPath: String##String#>) .changeCount
//        a.asObservable().subscribe(onNext: { debugPrint($0)}, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        //pasteboardObserver.addSubscriber(self)
        //pasteboardObserver.startObserving()

//        if AppCache.shared.appConfig.autoUp {
//            pasteboardObserver.startObserving()
//            autoUpItem.state = NSControl.StateValue(rawValue: 1)// 1
//        }

        /*

        NotificationCenter.default.rx.observe(<#T##type: E.Type##E.Type#>, <#T##keyPath: String##String#>)
        NotificationCenter.default.addObserver(self, selector: #selector(notification), name: NSNotification.Name(rawValue: "MarkdownState"), object: nil)
 */
        /*
        window.center()
        appDelegate = self
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        //NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        let statusBarButton = DragDestinationView(frame: (statusItem.button?.bounds)!)
        statusItem.button?.superview?.addSubview(statusBarButton, positioned: .below, relativeTo: statusItem.button)
        let iconImage = NSImage.init(named: NSImage.Name.init("StatusIcon"))// NSImage(named: "StatusIcon")
        iconImage?.isTemplate = true
        statusItem.button?.image = iconImage
        statusItem.button?.action = #selector(showMenu)
        statusItem.button?.target = self
        */
    }

    func registerHotKeys() {
        var gMyHotKeyRef: EventHotKeyRef? = nil
        var gMyHotKeyIDU = EventHotKeyID()
        var gMyHotKeyIDM = EventHotKeyID()
        var eventType = EventTypeSpec()

        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        gMyHotKeyIDU.signature = OSType(32)
        gMyHotKeyIDU.id = UInt32(kVK_ANSI_U);
        gMyHotKeyIDM.signature = OSType(46);
        gMyHotKeyIDM.id = UInt32(kVK_ANSI_M);


        RegisterEventHotKey(UInt32(kVK_ANSI_U), UInt32(cmdKey), gMyHotKeyIDU, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey), gMyHotKeyIDM, GetApplicationEventTarget(), 0, &gMyHotKeyRef)

        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), { (nextHanlder, theEvent, userData) -> OSStatus in
            var hkCom = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkCom)
            switch hkCom.id {
            case UInt32(kVK_ANSI_U):
                // TODO:
                // let pboard = NSPasteboard.general
                //ImageService.shared.uploadImg(pboard)
                break
            case UInt32(kVK_ANSI_M):
                break
                /*
                AppCache.shared.appConfig.linkType = LinkType(rawValue: 1 - AppCache.shared.appConfig.linkType.rawValue)!
                print(AppCache.shared.appConfig.linkType.rawValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MarkdownState"), object:  AppCache.shared.appConfig.linkType.rawValue)
                guard let imagesCache = AppCache.shared.imagesCacheArr.last else {
                    return 33
                }
                NSPasteboard.general.clearContents()
                let picUrl = imagesCache["url"] as! String
                NSPasteboard.general.setString(LinkType.getLink(path: picUrl, type: AppCache.shared.appConfig.linkType),
                                               forType: NSPasteboard.PasteboardType.string)
 */
            default:
                break
            }

            return 33
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)
    }
}

