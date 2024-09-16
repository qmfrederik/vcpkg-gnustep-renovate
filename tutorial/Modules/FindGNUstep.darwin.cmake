find_library(GNUSTEP_BASE Foundation REQUIRED)
find_library(GNUSTEP_GUI Cocoa REQUIRED)

add_library(GNUstep::Base SHARED IMPORTED)
set_target_properties(GNUstep::Base PROPERTIES
  IMPORTED_LOCATION "${GNUSTEP_BASE}")

add_library(GNUstep::GUI SHARED IMPORTED)
set_target_properties(GNUstep::GUI PROPERTIES
  IMPORTED_LOCATION "${GNUSTEP_GUI}")

add_library(GNUstep::GNUstep INTERFACE IMPORTED)
target_link_libraries(GNUstep::GNUstep INTERFACE GNUstep::GUI GNUstep::Base)
