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

### ios release_for_internal

```sh
[bundle exec] fastlane ios release_for_internal
```

Upload Release build to TestFlight - for internal release

### ios release_for_beta

```sh
[bundle exec] fastlane ios release_for_beta
```

Upload Release build to TestFlight - for beta release

### ios release

```sh
[bundle exec] fastlane ios release
```

Upload Release build to TestFlight

### ios debug_for_internal

```sh
[bundle exec] fastlane ios debug_for_internal
```

Upload Debug build to TestFlight

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Run unit tests

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
