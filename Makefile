project:
	swiftproj generate-xcodeproj --enable-code-coverage
	swiftproj add-system-framework --project URLNavigator.xcodeproj --target QuickSpecBase --framework Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework
