fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios staging_staging_release

```sh
[bundle exec] fastlane ios staging_staging_release
```

Upload Release build to TestFlight for staging staging

### ios staging_production_release

```sh
[bundle exec] fastlane ios staging_production_release
```

Upload Release build to TestFlight for staging production

### ios production_staging_release

```sh
[bundle exec] fastlane ios production_staging_release
```

Upload Release build to TestFlight for production staging

### ios production_production_release

```sh
[bundle exec] fastlane ios production_production_release
```

Upload Release build to TestFlight for production production

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Increase version number & build number.

### ios provision_devices

```sh
[bundle exec] fastlane ios provision_devices
```

Add new devices to provisioning profile

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
