import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase with graceful error handling
    // This allows the app to run even without valid Firebase configuration
    if FirebaseApp.app() == nil {
      // For simulator/development, we'll skip Firebase configuration
      // In production, you would want proper Firebase setup
      print("Firebase not configured - running in development mode")
    } else {
      do {
        try FirebaseApp.configure()
      } catch {
        print("Firebase configuration failed: \(error)")
      }
    }
    
    // Register for remote notifications (only if Firebase is configured)
    if FirebaseApp.app() != nil {
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
      }
      
      // Enable FCM auto-init
      Messaging.messaging().isAutoInitEnabled = true
      
      // Request notification permission
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if granted {
            DispatchQueue.main.async {
              application.registerForRemoteNotifications()
            }
          }
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

