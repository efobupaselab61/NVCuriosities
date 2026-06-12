# Firebase Setup

The app already includes Firebase Analytics and Firebase Cloud Messaging integration.

To activate it for a real Firebase project:

1. In Firebase Console, create or open the iOS app with bundle id `com.nv.curiosities`.
2. Download `GoogleService-Info.plist`.
3. Add that file to `NVCuriosities/` in Xcode and make sure it is included in the `NV Curiosities` target.
4. In Apple Developer, enable Push Notifications for the app identifier.
5. In Firebase Console, upload the APNs Auth Key or certificates under Project Settings > Cloud Messaging.
6. For release builds, keep `aps-environment` in `NVCuriosities/NV_Curiosities.entitlements` set to `production`.

The sample file `NVCuriosities/GoogleService-Info.example.plist` is documentation only and should not be used as the real Firebase config.
