#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h> 
#import <Foundation/Foundation.h>
#import "DVDeltaVisionHeader.h"

static const NSString *kDVItemKindName = @"Applied Precision DeltaVision Image";

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    DVDeltaVisionHeader *dvHeader = [[DVDeltaVisionHeader alloc]
                                     initWithContentsOfFile:(NSString *)pathToFile];
    
    if ( dvHeader == nil ) {
        [pool release];
        return FALSE;
    }
    
	[(NSMutableDictionary *)attributes 
     setObject:[dvHeader sizeX]
        forKey:(NSString *)kMDItemPixelHeight];
    
	[(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeY]
        forKey:(NSString *)kMDItemPixelWidth];

    [(NSMutableDictionary *)attributes
     setObject:[NSNumber numberWithInt:[dvHeader bytesPerPixel]*8]
     forKey:(NSString *)kMDItemBitsPerSample];

    [(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeX]
     forKey:@"org_openmicroscopy_OME_Pixels_SizeX"];

    [(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeY]
     forKey:@"org_openmicroscopy_OME_Pixels_SizeY"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeZ]
     forKey:@"org_openmicroscopy_OME_Pixels_SizeZ"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeC]
     forKey:@"org_openmicroscopy_OME_Pixels_SizeC"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader sizeT]
     forKey:@"org_openmicroscopy_OME_Pixels_SizeT"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader numPlanes]
     forKey:@"org_openmicroscopy_OME_Pixels_NumPlanes"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader dimensionOrder]
     forKey:@"org_openmicroscopy_OME_Pixels_DimensionOrder"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader omePixelType]
     forKey:@"org_openmicroscopy_OME_Pixels_PixelType"];
    
    [(NSMutableDictionary *)attributes
     setObject:[NSNumber numberWithBool:[dvHeader bigEndian]]
     forKey:@"org_openmicroscopy_OME_Pixels_BigEndian"];

    [(NSMutableDictionary *)attributes
     setObject:[dvHeader physicalSizeX]
     forKey:@"org_openmicroscopy_OME_Pixels_PhysicalSizeX"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader physicalSizeY]
     forKey:@"org_openmicroscopy_OME_Pixels_PhysicalSizeY"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader physicalSizeZ]
     forKey:@"org_openmicroscopy_OME_Pixels_PhysicalSizeZ"];
    
    [(NSMutableDictionary *)attributes
     setObject:[dvHeader channels]
     forKey:@"com_api_deltavision_ChannelWavelengths"];

    // use the first 80 chars of 'Title/Comments' as the title
	NSString *title = [dvHeader comment];
    NSRange firstLineRange = [title rangeOfCharacterFromSet:
                              [NSCharacterSet newlineCharacterSet]];
    if ( firstLineRange.location != NSNotFound ) {
        title = [title substringWithRange:firstLineRange];
    }
    [(NSMutableDictionary *)attributes
     setObject:title
        forKey:(NSString *)kMDItemTitle];
    
	// put the entire 'Titles/Comments section in kMDItemTextContent
	[(NSMutableDictionary *)attributes
     setObject:[dvHeader comment]
        forKey:(NSString *)kMDItemTextContent];
    
    [(NSMutableDictionary *)attributes
     setObject:kDVItemKindName forKey:(NSString *)kMDItemKind];
        
	[dvHeader release];
	[pool drain];
    return TRUE;
}
