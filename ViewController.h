//
//  ViewController.h
//  WordLinkProto
//
//  Created by B McCowan on 3/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    __weak IBOutlet UIButton *playB;
    NSDictionary *savedList; //plist of words stored in dictionary - to pass to Level Screen
    IBOutlet UIImageView *icon;
    IBOutlet UIButton *moreB;
}

- (void)playAnimation;
- (BOOL)plistCheck:(NSString*)filename;
- (NSString*)copyFileToDocumentDirectory:(NSString*)filename;

@end
