//
//  ViewController.m
//  WordLinkProto
//
//  Created by B McCowan on 3/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DifficultyController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create a path to plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistLoc = [documentsDirectory stringByAppendingPathComponent:@"WordList.plist"];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"WordList" ofType:@"plist"];
    NSDictionary* temp = [[NSDictionary alloc] initWithContentsOfFile:path];
    savedList = (NSDictionary*)[temp objectForKey:@"Root"];
    
    //set up word link shine animation
    NSArray* strArray = [NSArray arrayWithObjects:@"IconAnim1.png",@"IconAnim2.png",@"IconAnim3.png",@"IconAnim4.png",@"IconAnim5.png",@"IconAnim6.png",@"IconAnim7.png",@"IconAnim8.png", nil];
    NSMutableArray* animArray = [[NSMutableArray alloc] initWithCapacity:8];
    UIImage* image;
    
    for (int i=0 ; i<8 ; i++)
    {
        image = [UIImage imageNamed:[strArray objectAtIndex:i]];
        [animArray addObject:image];
    }
    icon.animationImages = animArray;
}
    
- (void)viewDidUnload
{
    playB = nil;
    icon = nil;
    moreB = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // set file manager object
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // upon first installation, copy plists to document directory    
    NSArray* plistFiles = [[NSArray alloc] initWithObjects:@"FirstTutorialValue.plist",@"ScoreData.plist",@"WordList.plist",@"purchased.plist",nil];
    
    for (int i=0 ; i<plistFiles.count ; i++)
    {
        // if file does not exist
        if ([manager fileExistsAtPath:[plistFiles objectAtIndex:i]] != YES)
            // create it
            [self copyFileToDocumentDirectory:[plistFiles objectAtIndex:i]];
            NSLog(@"%@ copied to doc dir.",[plistFiles objectAtIndex:i]);
             
    }
    
    // create a path to plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistLocation = [documentsDirectory stringByAppendingPathComponent:@"FirstTutorialValue.plist"];
    
    //NSString* path = [[NSBundle mainBundle] pathForResource:@"FirstTutorialValue" ofType:@"plist"];
    NSDictionary* temp = [[NSDictionary alloc] initWithContentsOfFile:plistLocation];
    NSDictionary* rootD = (NSDictionary*)[temp objectForKey:@"Root"];
    NSString* sFirstTutorial = [rootD objectForKey:@"sFirstTutorial"];
    if ([sFirstTutorial isEqualToString:@"YES"])
        [self performSegueWithIdentifier:@"HELP" sender:self];
    
    // wait 1 second before playing animation
    [NSTimer scheduledTimerWithTimeInterval:0.75f target:self selector:@selector(playAnimation) userInfo:nil repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // if play button pressed
    if ([[segue identifier] isEqualToString:@"PLAY"])
    {
        // pass list to difficulty view controller
        DifficultyController *vc = [segue destinationViewController];
        [vc loadDict:savedList];
        //NSLog(@"loadDict fxn called when PLAY segue called");
    }
    else
        NSLog(@"PLAY segue not called");
}

- (void)playAnimation;
{
    [icon setAnimationDuration:.75];
    [icon setAnimationRepeatCount:1];
    [icon startAnimating];

}

- (BOOL)plistCheck:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,                                                         NSUserDomainMask,                                                         YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *documentDirPath = [documentsDir
        stringByAppendingPathComponent:filename];
    NSFileManager* manager = [NSFileManager defaultManager];
    
    return [manager fileExistsAtPath:documentDirPath];
}

- (NSString *)copyFileToDocumentDirectory:(NSString *)fileName {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,                                                         NSUserDomainMask,                                                         YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *documentDirPath = [documentsDir
        stringByAppendingPathComponent:fileName];
    NSArray *file = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[file objectAtIndex:0] ofType:[file lastObject]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:documentDirPath];
    
    if (!success) {
        success = [fileManager copyItemAtPath:filePath toPath:documentDirPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable txt file file with message \'%@'.", [error localizedDescription]);
        }
    }
    
    return documentDirPath;
}

@end
