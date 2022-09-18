//
//  AppDelegate.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var popover = NSPopover()
    
    private lazy var contentView: NSView?  = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupManuBar()
        setupPopover()
    }
}

// MARK: - POPOVER

extension AppDelegate {
    func setupPopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = .init(width: 240, height: 240)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(
            rootView: PopoverView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        )
    }
}

// MARK: - MENU BAR

extension AppDelegate {
    func setupManuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: 64)
        guard let contentView = self.contentView,
              let menuButton = statusItem.button else { return }
        
        let hostingView = NSHostingView(rootView: MenuBarView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        menuButton.action = #selector(menuButtonClicked)
    }
    
    @objc func menuButtonClicked() {
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        
        guard let menuButton = statusItem.button else { return }
        popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
        popover.contentViewController?.view.window?.makeKey()
    }
}
