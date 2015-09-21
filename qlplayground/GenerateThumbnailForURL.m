@import CoreFoundation;
@import CoreServices;
@import QuickLook;
@import Cocoa;
#import "qlplayground-swift.h"


OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    CFDataRef data = (__bridge CFDataRef)[Highlight dataWithURL:(__bridge NSURL * _Nonnull)(url)];
    if (data) {
        NSDictionary *properties = @{
            (id)kQLThumbnailPropertyExtensionKey: [(__bridge NSURL*)url pathExtension]
        };
        QLThumbnailRequestSetThumbnailWithDataRepresentation(thumbnail, data, kUTTypeHTML, NULL, (__bridge CFDictionaryRef)(properties));
    }
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
