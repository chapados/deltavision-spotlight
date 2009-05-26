//
//  BCEndianData.m
//  DeltaVisionImporter
//
//  Created by chapbr on 5/21/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "BCEndianData.h"


static CFByteOrder hostEndian;

@implementation BCEndianData
@synthesize data = mData;

- (id) initWithData:(NSData *)theData;
{
    CFByteOrder endianness = NSHostByteOrder();
    return [self initWithData:theData byteOrder:endianness];
}

- (id) initWithData:(NSData *)theData byteOrder:(CFByteOrder)endianness;
{
    hostEndian = NSHostByteOrder();
    if ( self = [super init] ) {
        [self setData:theData];
        byteOrder = endianness;
    }
    return self;
}

- (void) dealloc
{
    [mData release];
    [super dealloc];
}

- (off_t) readBytes:(uint8_t *)bytes range:(NSRange)r;
{
    [mData getBytes:bytes range:r];
    return (r.location + r.length);
}

- (uint8_t) readCharAtOffset:(off_t)offset;
{
    uint8_t value;
    [mData getBytes:&value range:NSMakeRange(offset, 1)];
    return value;
}

- (int16_t) readShortAtOffset:(off_t)offset;
{
    int16_t value;
    [mData getBytes:&value range:NSMakeRange(offset, 2)];
    return (byteOrder == hostEndian) ? value : NSSwapShort(value);
}

- (off_t) readShort:(int16_t *)v atOffset:(off_t)offset;
{
    int16_t value;
    [mData getBytes:&value range:NSMakeRange(offset, 2)];
    *v = (byteOrder == hostEndian) ? value : NSSwapShort(value);
    return offset+2;
}

- (int16_t *) readShortWithRange:(NSRange)r;
{
    size_t size = sizeof(int16_t);
    int16_t *values = malloc(size * (r.length/size));
    [mData getBytes:values range:r];
    if ( byteOrder == hostEndian )
        return values;
    int16_t *v = values;
    while (v) {
        *v = NSSwapShort(*v++);
    }
    return values;
}

- (int32_t) readIntegerAtOffset:(off_t)offset;
{
    int32_t value;
    [mData getBytes:&value range:NSMakeRange(offset, 4)];
    return (byteOrder == hostEndian) ? value : NSSwapInt(value);
}

- (Float32) readFloatAtOffset:(off_t)offset;
{
    union CFSwap {
        Float32 v;
        CFSwappedFloat32 sv;
    } value;
    [mData getBytes:&value range:NSMakeRange(offset, 4)];
    return ( byteOrder == hostEndian ) ? value.v : CFConvertFloat32SwappedToHost(value.sv);
}
@end