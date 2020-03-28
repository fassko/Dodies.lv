fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios certificates
```
fastlane ios certificates
```
Certs
### ios register_test_devices
```
fastlane ios register_test_devices
```

### ios build_for_release
```
fastlane ios build_for_release
```
CI build
### ios test
```
fastlane ios test
```
Test
### ios derived_data
```
fastlane ios derived_data
```
Derived data
### ios beta
```
fastlane ios beta
```

### ios release_github
```
fastlane ios release_github
```
Deploy a new version to the App Store
### ios dsyms
```
fastlane ios dsyms
```
Download dSYMs and upload to Testflight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
