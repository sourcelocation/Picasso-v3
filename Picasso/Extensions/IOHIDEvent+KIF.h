#include <Foundation/Foundation.h> // this wasn't in the original trollspeed source release, but it's needed for nsarray later on. -bomberfish

typedef struct __IOHIDEvent * IOHIDEventRef;
IOHIDEventRef kif_IOHIDEventWithTouches(NSArray *touches) CF_RETURNS_RETAINED;
