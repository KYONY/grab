XCODEBUILD = xcodebuild -project Grab.xcodeproj -scheme Grab -configuration Debug -derivedDataPath build

.PHONY: build test run clean

build:
	$(XCODEBUILD) build

test:
	bash scripts/check-localization.sh
	$(XCODEBUILD) test

run: build
	open build/Build/Products/Debug/Grab.app

clean:
	rm -rf build
