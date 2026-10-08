#import "VendorLib.h"

// The app target compiles with its own GCC_PREPROCESSOR_DEFINITIONS (no SWIFT_PACKAGE),
// so the header takes the search-path branch and this builds fine.
int app_vendor_version(void) { return VENDOR_LIB_VERSION; }
