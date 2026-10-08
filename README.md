# Running a CocoaPods project's unit tests that do not build, in an isolated git worktree

Your app builds and runs, but the unit-test target does not even compile, and your main
checkout is full of uncommitted changes you do not want to disturb. This repo shows the
most confusing cause (a project-level `SWIFT_PACKAGE=1` inherited by the test target) with a
tiny CocoaPods-free project, plus the scripts for the worktree workflow.

## How to run

1. Open `Demo/Demo.xcodeproj` in Xcode 15+ (or `xed Demo`), pick an iPhone simulator.
   - Scheme **NaiveTests**, press Cmd-U: the build fails with
     `'../../Internal/VendorLibInternal.h' file not found`.
   - Scheme **FixedTests** (also the test action of scheme **Demo**), press Cmd-U: passes.
2. Terminal (pin the simulator by id):

   ```bash
   scripts/verify.sh            # asserts: NaiveTests fails to compile, FixedTests passes
   xcodebuild -project Demo/Demo.xcodeproj -scheme FixedTests -destination "id=<UDID>" test
   ```
3. The project is generated from `Demo/project.yml` with XcodeGen (`cd Demo && xcodegen`);
   the generated `Demo.xcodeproj` is committed, so XcodeGen is not required to run it.

## Symptom, cause, fix

| Symptom | Cause | Fix (test target only) |
| --- | --- | --- |
| `could not build module 'Pod'`, `module not found`, `'../../x.h' file not found` in pod headers | Project-level `GCC_PREPROCESSOR_DEFINITIONS = SWIFT_PACKAGE=1`. The app target overrides the key with its own list; the test target does not, so it inherits `SWIFT_PACKAGE=1` and the pods' headers take their `#ifdef SWIFT_PACKAGE` branch with source-relative imports | Set `GCC_PREPROCESSOR_DEFINITIONS` explicitly on the test target, without `$(inherited)` |
| `Unable to resolve module dependency: 'SomeFramework'` | `import SomeFramework` works in the app only through a recursive `HEADER_SEARCH_PATHS = $(SRCROOT)/Pods/**` that reaches the xcframework's `module.modulemap`; the test target lacks it | Add the same header search path to the test target |
| `compiling for iOS 14.0, but module 'App' has a minimum deployment target of iOS 16.0` | Test target `IPHONEOS_DEPLOYMENT_TARGET` is lower than the app module's | Raise the test target to the app's deployment target |
| Random Swift errors in test files (renamed API, `Void` return, `Any` is not `Equatable`) | Bit-rotted tests nobody compiled for a while | List all of them in one pass with `OTHER_SWIFT_FLAGS='$(inherited) -continue-building-after-errors'`, then fix or drop the dead files |

The demo reproduces the first row only (it is the one that needs a repro to believe); the
other rows are build-setting mismatches you can read straight from the error message.

## Scripts

- `scripts/run-tests-in-worktree.sh <branch> <project> <scheme> <udid> [-only-testing:Target/Suite]`:
  `git worktree add`, `pod install` inside it, re-apply overrides, run the tests. The main
  checkout is not touched.
- `scripts/apply-test-target-overrides.rb`: the three overrides, as a script. Generators that
  rewrite the pbxproj wipe local overrides, so re-apply before every run.
- `scripts/commit-pbxproj-with-noise.sh`: commit a pbxproj change while the working tree has
  unrelated modifications (edit a `git show HEAD:` copy, swap it in, pathspec commit, restore).
- `scripts/verify.sh`: the demo's proof.

Do not use a shared scheme with a build pre-action script for this: the pre-action may run a
generator that rewrites the project. Use a dedicated scheme that contains only the test target.

## CI

`.github/workflows/ci.yml` runs `scripts/verify.sh` on a hosted macOS runner. The real-world
CocoaPods setup (private pods, vendor xcframeworks) cannot be reproduced on a hosted runner,
which is why the demo is CocoaPods-free.

Write-up: https://alexeyhatkevich.blogspot.com
