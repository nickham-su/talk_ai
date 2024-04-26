import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false // true 为关闭窗口后退出程序，false 为关闭窗口后程序继续运行
  }

  // 点击 dock 图标时，显示窗口
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
      if !flag {
          for window in NSApp.windows {
              if !window.isVisible {
                  window.setIsVisible(true)
              }
              window.makeKeyAndOrderFront(self)
              NSApp.activate(ignoringOtherApps: true)
          }
      }
      return true
  }
}
