//
//  dv-dump-header.m
//  DeltaVisionImporter
//
//  Created by chapbr on 5/21/09.
//  Copyright 2009 Brian Chapados. All rights reserved.
//
#import <stdio.h>
#import <Foundation/Foundation.h>
#import "DVDeltaVisionHeader.h"

int main(int argc, const char *argv[])
{
    if ( argc < 2 || argc > 3 ) {
        printf("usage:\n");
        printf("dv-dump-header <deltavision image file>\n");
        exit(0);
    }
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *inputFile = [[NSString alloc] initWithCString:argv[1]];
    NSLog(@"inputFile = %@", inputFile);
    DVDeltaVisionHeader *header = [[DVDeltaVisionHeader alloc] initWithContentsOfFile:inputFile];
    [header dump];
    
    [inputFile release];
    [header release];
    [pool drain];
    
    return 0;
}
