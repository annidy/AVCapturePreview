//
//  CameraView.m
//  AVCapturePreview
//
//  Created by annidyfeng on 16/4/8.
//  Copyright © 2016年 annidyfeng. All rights reserved.
//

#import "CameraView.h"

@implementation CameraView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    CGContextRef context =  [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.5);
    CGContextFillRect(context, NSRectFromCGRect(dirtyRect));
    
    self.layer.borderColor = [NSColor blackColor].CGColor;
    self.layer.borderWidth = 1;
}

@end
