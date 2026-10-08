#!/usr/bin/env ruby
# Re-apply local, test-target-only build-setting overrides to an .xcodeproj.
# Keep this in a script: any generator step that rewrites the project wipes
# hand-made overrides, so you run this before every test run.
#
# usage: ruby apply-test-target-overrides.rb <path/to/App.xcodeproj> [TestTargetName]
#
# Requires the `xcodeproj` gem (it ships with CocoaPods).
require 'xcodeproj'

path   = ARGV[0] or abort 'usage: apply-test-target-overrides.rb <project> [target]'
target = ARGV[1] || ENV['TEST_TARGET'] || 'AppTests'
# Edit these for your project:
overrides = {
  # 1. Explicit list, NO $(inherited): drops a project-level SWIFT_PACKAGE=1.
  'GCC_PREPROCESSOR_DEFINITIONS' => 'TESTS=1',
  # 2. Let the test target see the xcframework's module.modulemap the same way the app does.
  'HEADER_SEARCH_PATHS'          => '$(inherited) $(SRCROOT)/Pods/**',
  # 3. Match the app module's minimum deployment target.
  'IPHONEOS_DEPLOYMENT_TARGET'   => '16.0',
}

project = Xcodeproj::Project.open(path)
t = project.targets.find { |x| x.name == target } or abort "no target #{target}"
t.build_configurations.each { |c| overrides.each { |k, v| c.build_settings[k] = v } }
project.save
puts "applied #{overrides.keys.join(', ')} to #{target}"
