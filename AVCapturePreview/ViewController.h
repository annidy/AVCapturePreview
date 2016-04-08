//
//  ViewController.h
//  AVCapturePreview
//
//  Created by annidyfeng on 16/4/8.
//  Copyright © 2016年 annidyfeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "CameraView.h"
@import AVFoundation;

@interface ViewController : NSViewController

@property (weak) IBOutlet CameraView *cameraView;
@property (weak) IBOutlet NSImageView *stillImageView;

@end

