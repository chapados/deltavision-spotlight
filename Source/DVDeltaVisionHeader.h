//
//  DVDeltaVisionHeader.h
//  DeltaVisionImporter
//
//  Created by chapbr on 5/21/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kDVPixelTypeUnknown = -1,
    kDVPixelTypeByte = 0, // uint8_t
    kDVPixelTypeShort = 1, // int16_t
    kDVPixelTypeFloat = 2, // float
    kDVPixelTypeFloatComplex = 3, // ?
    kDVPixelTypeDoubleComplex = 4, // ?
    kDVPixelTypeUnused = 5, // ?
    kDVPixelTypeUShort = 6, // uint16_t
    kDVPixelTypeLong = 7, // long
    kDVPixelTypeDouble = 8, // double
} DVPixelType;

typedef enum {
    kDVImageSequenceZTC,
    kDVImageSequenceCZT,
    kDVImageSequenceZCT,
} DVImageSequence;

@interface DVDeltaVisionHeader : NSObject {
    CFByteOrder byteOrder;
    
    // derived field values
    NSUInteger width;
    NSUInteger height;
    NSUInteger imageCount;
    NSUInteger depth;
    NSUInteger timeCount;
    Float32 physicalSizeX;
    Float32 physicalSizeY;
    Float32 physicalSizeZ;
    DVImageSequence imageSequence;
    DVPixelType pixelType;
    NSUInteger channelCount;
    NSUInteger channelWaveLengths[5];
    NSUInteger extendedHeaderSize;
    NSUInteger commentCount;
    NSString *comment;
}
// header/image properties
@property (readonly) NSUInteger width;
@property (readonly) NSUInteger height;
@property (readonly) NSUInteger depth;
@property (readonly) NSUInteger timeCount;
@property (readonly) NSUInteger channelCount;
@property (retain, readonly) NSString *comment;
@property (readonly) NSArray *channels;
@property (readonly) NSUInteger bytesPerPixel;

- (id) initWithData:(NSData *)theData;
- (id) initWithData:(NSData *)theData byteOrder:(CFByteOrder)byteOrder;
- (id) initWithContentsOfFile:(NSString *)filePath;

- (void) dump;
@end

@interface DVDeltaVisionHeader (OMEMetadata)
- (NSNumber *) sizeX;
- (NSNumber *) physicalSizeX;
- (NSNumber *) sizeY;
- (NSNumber *) physicalSizeY;
- (NSNumber *) sizeZ;
- (NSNumber *) physicalSizeZ;
- (NSNumber *) sizeC;
- (NSNumber *) sizeT;
- (NSNumber *) numPlanes;
- (NSString *) omePixelType;
- (NSString *) dimensionOrder;
- (BOOL) bigEndian;
@end
