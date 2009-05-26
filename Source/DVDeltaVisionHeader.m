//
//  DVDeltaVisionHeader.m
//  DeltaVisionImporter
//
//  Created by chapbr on 5/21/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import "DVDeltaVisionHeader.h"
#import "BCEndianData.h"

const int16_t kDVLittleEndian = 0xc0a0;
const int16_t kDVBigEndian = 0xa0c0;
const uint16_t kDVHeaderLength = 1024;
const NSUInteger kDVCommentMaxLines = 10;
const NSUInteger kDVCommentLineLength = 80;

enum {
    kDVHeaderOffsetWidth = 0,
    kDVHeaderOffsetHeight = 4,
    kDVHeaderOffsetImageCount = 8,
    kDVHeaderOffsetPixelType = 12,
    kDVHeaderOffsetPhysicalSizeX = 40,
    kDVHeaderOffsetPhysicalSizeY = 44,
    kDVHeaderOffsetPhysicalSizeZ = 48,
    kDVHeaderOffsetExtendedHeaderSize = 92,
    kDVHeaderOffsetEndian = 96,
    kDVHeaderOffsetTimeCount = 180,
    kDVHeaderOffsetImageSequence = 182,
    kDVHeaderOffsetChannelCount = 196,
    kDVHeaderOffsetChannelWaveLength0 = 198,
    kDVHeaderOffsetChannelWaveLength1 = 200,
    kDVHeaderOffsetChannelWaveLength2 = 202,
    kDVHeaderOffsetChannelWaveLength3 = 204,
    kDVHeaderOffsetChannelWaveLength4 = 206,
    kDVHeaderOffsetCommentCount = 222,
    kDVHeaderOffsetComments = 224,
};


@interface DVDeltaVisionHeader()
- (void) parseData:(NSData *)theData;
- (NSString *) parseCommentWithData:(NSData *)theData;
@property (readwrite, retain) NSString *comment;
@end


@implementation DVDeltaVisionHeader
@synthesize width, height, depth, timeCount, channelCount;
@synthesize comment;
@dynamic channels, bytesPerPixel;

BOOL isValidDVHeader(NSData *theData)
{
    int16_t dvEndian;
    [theData getBytes:&dvEndian range:NSMakeRange(kDVHeaderOffsetEndian, 2)];
    return (BOOL)(dvEndian == kDVLittleEndian || dvEndian == kDVBigEndian);
}

CFByteOrder DVByteOrder(NSData *theData)
{
    int16_t dvEndian;
    [theData getBytes:&dvEndian range:NSMakeRange(kDVHeaderOffsetEndian, 2)];
    if ( dvEndian == kDVLittleEndian ) {
        return NS_LittleEndian;
    }
    if ( dvEndian == kDVBigEndian ) {
        return NS_BigEndian;
    }
    return NS_UnknownByteOrder;
}

- (id) initWithContentsOfFile:(NSString *)filePath
{
    NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if ( !f ) {
        [self release];
        return nil;
    }
    
    NSData *d;
    @try {
        d = [f readDataOfLength:kDVHeaderLength];
    }
    @catch (NSException *e) {
        // BRC: we're doomed.
    }
    @finally {
        [f closeFile];
    }
    
    return [self initWithData:d];
}

- (id) initWithData:(NSData *)theData;
{
    if ( !(theData && isValidDVHeader(theData)) ) {
        [self release];
        return nil;
    }
    CFByteOrder endianness = DVByteOrder(theData);
    return [self initWithData:theData byteOrder:endianness];
}

- (id) initWithData:(NSData *)theData byteOrder:(CFByteOrder)endianness
{
    if (self = [super init]) {
        byteOrder = endianness;
        [self parseData:theData];
    }
    return self;
}

- (void) dealloc
{
    [comment release];
    [super dealloc];
}

- (void) parseData:(NSData *)theData;
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    BCEndianData *reader = [[BCEndianData alloc]
                                   initWithData:theData
                                   byteOrder:byteOrder];
    width = [reader readIntegerAtOffset:kDVHeaderOffsetWidth];
    height = [reader readIntegerAtOffset:kDVHeaderOffsetHeight];
    imageCount = [reader readIntegerAtOffset:kDVHeaderOffsetImageCount];
    pixelType = [reader readIntegerAtOffset:kDVHeaderOffsetPixelType];
    physicalSizeX = [reader readFloatAtOffset:kDVHeaderOffsetPhysicalSizeX];
    physicalSizeY = [reader readFloatAtOffset:kDVHeaderOffsetPhysicalSizeY];
    physicalSizeZ = [reader readFloatAtOffset:kDVHeaderOffsetPhysicalSizeZ];
    extendedHeaderSize = [reader readIntegerAtOffset:kDVHeaderOffsetExtendedHeaderSize];
    imageSequence = [reader readShortAtOffset:kDVHeaderOffsetImageSequence];
    timeCount = [reader readShortAtOffset:kDVHeaderOffsetTimeCount];
    channelCount = [reader readShortAtOffset:kDVHeaderOffsetChannelCount];
    
    off_t offset = kDVHeaderOffsetChannelWaveLength0;
    offset = [reader readShort:(int16_t *)&channelWaveLengths[0] atOffset:offset];
    offset = [reader readShort:(int16_t *)&channelWaveLengths[1] atOffset:offset];
    offset = [reader readShort:(int16_t *)&channelWaveLengths[2] atOffset:offset];
    offset = [reader readShort:(int16_t *)&channelWaveLengths[3] atOffset:offset];
    offset = [reader readShort:(int16_t *)&channelWaveLengths[4] atOffset:offset];
    
    depth = imageCount / (timeCount * channelCount);
    commentCount = [reader readShortAtOffset:kDVHeaderOffsetCommentCount];
    NSString *c = [self parseCommentWithData:theData];
    [self setComment:c];
    
    [reader release];
    [pool drain];
}


- (NSString *) parseCommentWithData:(NSData *)theData
{
    NSMutableArray *comments = [NSMutableArray new];
    char lines[kDVCommentMaxLines][kDVCommentLineLength];
    
    [theData getBytes:&lines range:NSMakeRange(kDVHeaderOffsetComments,
                                        (kDVCommentMaxLines*kDVCommentLineLength))];
    
    int i;
    for (i = 0; i < commentCount; i++) {
        char *c = (char *)lines[i];
        NSString *s = [[NSString alloc] initWithCString:c encoding:NSASCIIStringEncoding];
        if ( [s length] > 0 )
            [comments addObject:s];
        [s release];
    }

    NSString *commentLines = [comments componentsJoinedByString:@"\n"];
    [comments release];
    return commentLines;
}

- (NSArray *) channels;
{
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:channelCount];
    int i;
    for (i = 0; i < channelCount; i++) {
        NSNumber *n = [[NSNumber alloc] initWithInt:channelWaveLengths[i]];
        [channels addObject:n];
        [n release];
    }
    return [NSArray arrayWithArray:channels];
}

- (NSUInteger) bytesPerPixel;
{
    switch (pixelType) {
        case kDVPixelTypeByte:
            return 1;
        case kDVPixelTypeShort:
        case kDVPixelTypeUShort:
            return 2;
        case kDVPixelTypeFloat:
        case kDVPixelTypeFloatComplex:
            return 4;
        case kDVPixelTypeLong:
        case kDVPixelTypeDouble:
        case kDVPixelTypeDoubleComplex:
            return 8;
    }
    return 0;
}

- (void) dump;
{
    fprintf(stdout, "%d images: ", imageCount);
    fprintf(stdout, "x = %d, y = %d, z = %d, c = %d, t = %d\n",
            width, height, depth, channelCount, timeCount);
    fprintf(stdout, "physical size: x = %g, y = %g, z = %g\n", physicalSizeX, physicalSizeY, physicalSizeZ);
    fprintf(stdout, "[pixelType = %d] bits per pixel = %d\n", pixelType, [self bytesPerPixel]*8);
    fprintf(stdout, "imageSequence = %d\n", imageSequence);
    int i;
    for (i = 0; i < channelCount; i++ ) {
        fprintf(stdout, "[%d] = %d\n", i, channelWaveLengths[i]);
    }
    fprintf(stdout, "%s\n", [comment UTF8String]);
}

@end



@implementation DVDeltaVisionHeader (OMEMetadata)

- (NSNumber *) sizeX;
{
    return [NSNumber numberWithInt:width];
}

- (NSNumber *) physicalSizeX;
{
    return [NSNumber numberWithFloat:physicalSizeX];
}

- (NSNumber *) sizeY;
{
    return [NSNumber numberWithInt:height];
}

- (NSNumber *) physicalSizeY;
{
    return [NSNumber numberWithFloat:physicalSizeY];
}

- (NSNumber *) sizeC;
{
    return [NSNumber numberWithInt:channelCount];
}

- (NSNumber *) sizeZ;
{
    return [NSNumber numberWithInt:depth];
}

- (NSNumber *) physicalSizeZ;
{
    return [NSNumber numberWithFloat:physicalSizeZ];
}

- (NSNumber *) sizeT;
{
    return [NSNumber numberWithInt:timeCount];
}

- (NSNumber *) numPlanes;
{
    return [NSNumber numberWithInt:imageCount];
}

- (NSString *) omePixelType;
{
    switch (pixelType) {
        case kDVPixelTypeByte:
            return @"int8";
        case kDVPixelTypeShort:
            return @"int16";
        case kDVPixelTypeUShort:
            return @"uint16";
        case kDVPixelTypeFloat:
            return @"float";
        case kDVPixelTypeFloatComplex:
            return @"complex";
        case kDVPixelTypeLong:
            return @"int32";
        case kDVPixelTypeDouble:
            return @"double";
        case kDVPixelTypeDoubleComplex:
            return @"double-complex";
    }
    // exception?
    return @"unknown";
}

- (NSString *) dimensionOrder;
{
    switch (imageSequence) {
        case kDVImageSequenceCZT:
            return @"XYCZT";
        case kDVImageSequenceZCT:
            return @"XYZCT";
        case kDVImageSequenceZTC:
            return @"XYZTC";
    }
    // exception?
    return @"";
}

- (BOOL) bigEndian;
{
    return ( byteOrder == NS_BigEndian );
}

@end


