project:
	swiftproj generate-xcodeproj --enable-code-coverage
	swiftproj add-system-framework --project URLNavigator.xcodeproj --target QuickSpecBase --framework Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework

archive:
	swiftproj generate-xcconfig --podspec URLNavigator.podspec
	swiftproj generate-xcodeproj --xcconfig-overrides Config.xcconfig
	swiftproj add-system-framework \
	  --project URLNavigator.xcodeproj \
	  --target QuickSpecBase \
	  --framework Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework
	swiftproj configure-scheme \
	  --project URLNavigator.xcodeproj \
	  --scheme URLNavigator-Package \
	  --buildable-targets URLNavigator,URLMatcher
	carthage build --no-skip-current --verbose | xcpretty -c
	carthage archive URLNavigator URLMatcher
