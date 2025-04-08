//
//  AppDelegate.swift
//  waveform
//
//  Created by shimizu on 2025/04/08.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    // 起動完了時に呼び出す
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = CircularVisualizerView()

        let screenRect = NSScreen.main?.frame
        
        // 初期化
        window = NSWindow(
            contentRect: screenRect!, // ウィンドウのサイズを画面全体に設定
            styleMask: [.borderless], // ウィンドウのスタイルをタイトルバーやボタンなしに設定
            backing: .buffered,
            defer: false
        )
        // .desktopIconWindow:デスクトップ背景より手前 & フォルダアイコンより後ろ
        window.level = .init(Int(CGWindowLevelForKey(.desktopIconWindow)))
        // ウィンドウが透明にできる
        window.isOpaque = false
        // 背景色を透明
        window.backgroundColor = .clear
        // 影を無効化
        window.hasShadow = false
        // マウスイベントを無視
        window.ignoresMouseEvents = true
        
        window.collectionBehavior = [
            // 全ての仮想デスクトップに表示
            .canJoinAllSpaces,
            // 切り替えても移動しないように
            .stationary,
            // Cmd + Tab でのアプリ切り替えなどから除外
            .ignoresCycle
        ]

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = screenRect!
        window.contentView = hostingView
        // ウィンドウを画面に表示する
        window.makeKeyAndOrderFront(nil)
    }
}
