#import <XCTest/XCTest.h>
#import "VendorLib.h"

// The SAME source file is compiled into NaiveTests and FixedTests.
// In NaiveTests it cannot even compile: the header takes its SWIFT_PACKAGE branch.
@interface VendorLibTests : XCTestCase
@end

@implementation VendorLibTests

// Proves: with the define overridden, the header resolves and the macro is visible.
- (void)test_fixed_headerResolvesViaSearchPath {
    XCTAssertEqual(VENDOR_LIB_VERSION, 3);
}

// Proves: the fixed target does not carry the inherited SWIFT_PACKAGE define.
- (void)test_fixed_doesNotInheritSwiftPackageDefine {
#ifdef SWIFT_PACKAGE
    XCTFail(@"SWIFT_PACKAGE leaked into the test target");
#endif
}

@end
