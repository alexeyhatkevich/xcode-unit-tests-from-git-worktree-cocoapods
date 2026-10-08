// Stand-in for a CocoaPods pod's public header.
//
// Many libraries ship ONE header tree for both SwiftPM and CocoaPods and
// branch on SWIFT_PACKAGE. The SwiftPM branch uses source-relative paths that
// only exist in the package layout; the other branch relies on header search
// paths (what CocoaPods sets up).
#ifdef SWIFT_PACKAGE
#import "../../Internal/VendorLibInternal.h"   // does not exist in this layout
#else
#import "VendorLibInternal.h"                  // found via HEADER_SEARCH_PATHS
#endif
