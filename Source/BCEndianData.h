//
//  BCEndianData.h
//  DeltaVisionImporter
//
//  Created by chapbr on 5/21/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

@interface BCEndianData : NSObject {
    CFByteOrder byteOrder;
    NSData *mData;
}
@property (readwrite, retain) NSData *data;

- (id) initWithData:(NSData *)theData;
- (id) initWithData:(NSData *)theData byteOrder:(CFByteOrder)byteOrder;

- (uint8_t) readCharAtOffset:(off_t)offset;
- (int16_t) readShortAtOffset:(off_t)offset;
- (off_t) readShort:(int16_t *)v atOffset:(off_t)offset;
- (int32_t) readIntegerAtOffset:(off_t)offset;
- (float) readFloatAtOffset:(off_t)offset;
@end
