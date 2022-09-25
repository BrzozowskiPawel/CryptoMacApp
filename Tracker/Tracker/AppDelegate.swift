//
//  AppDelegate.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var menuBarViewModel: MenuBarViewModel!
    var popoverViewModel: PopoverViewModel!
    
    var statusItem: NSStatusItem!
    var popover = NSPopover()
    let coinService = CoinService()
    
    private lazy var contentView: NSView?  = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupCoinService()
        setupManuBar()
        setupPopover()
    }
    
    func setupCoinService() {
        coinService.connect()
        coinService.startMonitoringNetwork()
    }
}

// MARK: - POPOVER

extension AppDelegate: NSPopoverDelegate {
    func setupPopover() {
        popoverViewModel = .init(service: coinService)
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = .init(width: 240, height: 240)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(
            rootView: PopoverView(viewModel: popoverViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        )
        popover.delegate = self
    }
    
    func popoverDidClose(_ notification: Notification) {
        let positioningView = statusItem.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier("positioningView")
        }
        positioningView?.removeFromSuperview()
    }
}

// MARK: - MENU BAR

extension AppDelegate {
    func setupManuBar() {
        menuBarViewModel = MenuBarViewModel(service: coinService)
        statusItem = NSStatusBar.system.statusItem(withLength: 64)
        guard let contentView = self.contentView,
              let menuButton = statusItem.button else { return }
        
        let hostingView = NSHostingView(rootView: MenuBarView(viewModel: menuBarViewModel))
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
        
        let positioningView = NSView(frame: menuButton.bounds)
        positioningView.identifier = NSUserInterfaceItemIdentifier("positioningView")
        menuButton.addSubview(positioningView)
        
        popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
        menuButton.bounds = menuButton.bounds.offsetBy(dx: 0, dy: menuButton.bounds.height)
        popover.contentViewController?.view.window?.makeKey()
    }
}
