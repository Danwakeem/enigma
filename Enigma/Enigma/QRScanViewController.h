//
//  QRScanViewController.h
//  Enigma
//
//  Created by Bradley Slayter on 4/25/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AMScanViewControllerDelegate;

@interface AMScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<AMScanViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

@end

@protocol AMScanViewControllerDelegate <NSObject>

@optional

- (void) scanViewController:(AMScanViewController *) aCtler didTapToFocusOnPoint:(CGPoint) aPoint;
- (void) scanViewController:(AMScanViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

@end
