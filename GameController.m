//
//  GameController.m
//  WordLinkProto
//
//  Created by B McCowan on 4/23/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"
#import <UIKit/UITextChecker.h>

@implementation GameController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up win screen button actions
    [winNextB addTarget:self action:@selector(arrowRight:) forControlEvents:UIControlEventTouchUpInside];
    [winAgainB addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
    
    // hide win screen items
    [winBackground setHidden:YES];
    [winLabel setHidden:YES];
    [winNextB setHidden:YES];
    [winAgainB setHidden:YES];
    
    // store lastWord's position (for use in loadNewWord)
    lastWordRect = lastWord.frame;
}

- (void)viewDidUnload
{
    swipeDown = nil;
    scroll = nil;
    firstWord = nil;
    lastWord = nil;
    view = nil;
    playsB = nil;
    bestB = nil;
    restartB = nil;
    winBackground = nil;
    winLabel = nil;
    winNextB = nil;
    winAgainB = nil;
    navItem = nil;
    toolbar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // create a path to plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path= [documentsDirectory stringByAppendingPathComponent:@"ScoreData.plist"];
    //path = [[NSBundle mainBundle] pathForResource:@"ScoreData" ofType:@"plist"];
    dictP = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // set up for new level (the first level)
    [self newLevel:1];
    
    // scroll view background set to clear
    [scroll setBackgroundColor:[UIColor clearColor]];
    
    // set up back button on navigation bar
    // create back button image and button
    UIImage* backImage = [UIImage imageNamed:@"navBackB.png"];
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,50,30)];
    // set the image for the button
    [backButton setImage:backImage forState:UIControlStateNormal];
    // set up button action to go back (pop view controller)
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    // initialize bar button with the back button
    UIBarButtonItem* backBItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    // set the left bar button as the back bar item
    navItem.leftBarButtonItem = backBItem;
    
    // create back button image and button
    UIImage* restartImage = [UIImage imageNamed:@"restartB.png"];
    UIButton* restartButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    // set the image for the button
    [restartButton setImage:restartImage forState:UIControlStateNormal];
    // set up button action to go back (pop view controller)
    [restartButton addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
    // initialize bar button with the back button
    restartB = [[UIBarButtonItem alloc] initWithCustomView:restartButton];
    // set the right bar button as the restart bar item
    navItem.rightBarButtonItem = restartB;
    
    // create left arrow image and button
    UIImage* leftImage = [UIImage imageNamed:@"leftArrowB.png"];
    UIButton* lButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    // set the image for the button
    [lButton setImage:leftImage forState:UIControlStateNormal];
    // set up button action to go back (pop view controller)
    [lButton addTarget:self action:@selector(arrowLeft:) forControlEvents:UIControlEventTouchUpInside];
    // initialize bar button item and disable it
    arrowLB = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    [arrowLB setEnabled:NO];
    // create the right arrow image and button
    UIImage* rightImage = [UIImage imageNamed:@"rightArrowB.png"];
    UIButton* rButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    // set the image for the button
    [rButton setImage:rightImage forState:UIControlStateNormal];
    // set up button action to go back (pop view controller)
    [rButton addTarget:self action:@selector(arrowRight:) forControlEvents:UIControlEventTouchUpInside];
    // initialize bar button with the back button
    arrowRB = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    
    // setup the fixed space bar button items
    UIBarButtonItem* fixedSpaceLong = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    UIBarButtonItem* fixedSpaceShort = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    [fixedSpaceLong setWidth:100];
    [fixedSpaceShort setWidth:25];
    
    // add bar button items to list
    [toolbar setItems:[[NSArray alloc] initWithObjects:fixedSpaceLong,arrowLB,fixedSpaceShort,arrowRB, nil]];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setWordLength:(int)length
{
    // used by letter controllers to set word length (3-5)
    wordLength = length;
}

- (void)loadWordList:(NSArray *)list
{
    // load appropriate stage's word list passed from level controller
    wordList = [[NSArray alloc] initWithArray:list];
}

- (void)loadNewWord:(int)lvl
{
    // set current LEVEL
    LEVEL=lvl;
    
    // get appropriate level
    NSArray* lvlArray = (NSArray*)[wordList objectAtIndex:lvl-1];
    //NSLog(@"word one is %@",[lvlArray objectAtIndex:0]);
    
    // animate text
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:lastWord cache:YES];
    [UIView commitAnimations];
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:firstWord cache:YES];
    [UIView commitAnimations];
    
    // set text labels and positioning
    [firstWord setText:(NSString*)[lvlArray objectAtIndex:0]];
    [lastWord setText:(NSString*)[lvlArray objectAtIndex:1]];
    lastWord.frame = lastWordRect;
    //NSLog(@"first word is %@.\nlast word is %@",[firstWord text],[lastWord text]);
}

- (BOOL)textFieldShouldReturn:(id)sender
{
    reEdit = NO;
    //NSLog(@"word length is %i",wordLength);
    UITextField* textField = (UITextField*)sender;
    NSString* uiTex = [textField text];
    //NSLog(@"textfieldshouldreturn text is %@",uiTex);
    
    // for reediting purposes - if next field is not blank
    
    /*if (reEdit == YES && strcmp(acFields[currentTag-1], "") != 1)
    {
        NSLog(@"field after editing field is NOT blank");
        // check if current word links with the NEXT word
        [self wordCheck:uiTex];
    }
     */
    
    // if the current field has text..
    if ([(UITextField*)sender hasText] == YES)
    {
        // store text in array
        currentTag = [sender tag];
        
        if ((acFields[currentTag-1] == nil) || (strcmp(acFields[currentTag-1],"") == 1))
        {
            [aFields addObject:uiTex];
            //NSLog(@"%@ object added",uiTex);
        }
        else
        {
            [aFields replaceObjectAtIndex:currentTag-1 withObject:uiTex];
            //NSLog(@"%@ object replaced",uiTex);
        }
        //NSLog(@"array size is %i",aFields.count);
        
        acFields[currentTag-1] = uiTex.lowercaseString.UTF8String;
        //NSLog(@"aFields 0 is %s",aFields[0]);
        
        // update plays number
        NSString* playsText = [[NSString alloc] initWithFormat:@"Links: %i",aFields.count];
        [playsB setText:playsText];
        
        // get prior text (for isWord fxn)
        const char* priorTxt;
        if (currentTag == 1)
            priorTxt = "";
        else
        {
            //priorTxt = aFields[currentTag-2];
            priorTxt = [(NSString*)[aFields objectAtIndex:currentTag-2]UTF8String];
        }
        //NSLog(@"prior text is %s",priorTxt);
        NSString* priorText = [[NSString alloc] initWithFormat:@"%s",priorTxt];
        
        //NSLog(@"currentTag is %i",currentTag);
        // check if word
        if ([self isWord:uiTex] == YES && [uiTex length] == wordLength)
        {
            // run word link fxn
            if ([self wordLink:uiTex getPriorText:priorText getField:textField] == YES) 
            {
                // set text color to green
                [textField setTextColor:green];
                error = NO;
                
                // check if user won
                if ([self winTest:uiTex getField:textField] == YES)
                {
                    // user won, show animation
                    [self linkAnimation];
                    
                    // close kb
                    [textField resignFirstResponder];
                    
                    return YES;
                }
                else
                {
                    //NSLog(@"WORD LINKS.");
                }
                
            }
            else
            {
                [textField setTextColor:red];
                error = YES;
                errorPos = currentTag;
                //NSLog(@"WORD DOESN'T LINK!");
                [textField resignFirstResponder];
            }
        }
        else
        {
            // set text color to red
            [textField setTextColor:red];
            error = YES;
            errorPos = currentTag;
            NSLog(@"NOT A WORD or RE-EDIT ERROR.");
            [textField resignFirstResponder];
        }
    }
    
    // enable tap (keyboard is down)
    [firstTap setEnabled:YES];
    
    // if this fxn was not called with a swipe...
    if (kbId != 1 )
    {
        [self createB];
    }
    else
    {
        // reset kbId to default (see closeKb fxn)
        kbId = 0;
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)wordLink:(NSString*)text getPriorText:(NSString*)priorText getField:(UITextField *)textField
{
    // check if current word links with the PREVIOUS word
    
    diffCount = 0;
    // if currentTag ==1, compare w/ label
    NSString* textComp;
    if (currentTag == 1)
        textComp = [[NSString alloc] initWithString:[firstWord text]];
    else
        textComp = [[NSString alloc] initWithString:priorText];
    
    NSLog(@"prior text is %@",priorText);
    NSLog(@"current text is %@",text);
    
    // text must equal previous word minus one letter
    if ([text length] == [textComp length])
    {
        for (int i=0 ; i<[text length] ; i++)
        {
            if ([text characterAtIndex:i] != [textComp characterAtIndex:i])
                diffCount++;
        }
    }
    
    if (diffCount == 1)
        return YES;
    else
        return NO;
}

- (BOOL)wordCheck:(NSString *)text
{
    // check if current word links with the NEXT word
    
    diffCount = 0;
    // field after current one
    NSLog(@"how bout now?");
    NSString* nextText = (NSString*)[aFields objectAtIndex:currentTag];
    
    NSLog(@"wordCheck fxn - current field is %@",text);
    NSLog(@"wordCheck fxn - next field is %@",nextText);
    
    // text must equal previous word minus one letter
    if ([text length] == [nextText length])
    {
        for (int i=0 ; i<[text length] ; i++)
        {
            if ([text characterAtIndex:i] != [nextText characterAtIndex:i])
                diffCount++;
        }
    }
    
    UITextField* nextField = (UITextField*)[self.view viewWithTag:currentTag+2];
    
    if (diffCount == 1)
    {
        // set next field's text to green
        [nextField setTextColor:green];
        error = NO;
        return YES;
    }
    else
    {
        // set next field's text to red
        [nextField setTextColor:red];
        error = YES;
        errorPos = currentTag+2;
        return NO;
    }
}

- (BOOL)winTest:(NSString*)text getField:(UITextField*)textField
{
    // Finds the textField (with text) nearest the end, 
    // and tests to see if it links with the last word
    // if so, it test the entire the list of fields to
    // see if they all link with each other
    // if so, the user wins
    
    // check if priorText is one diffCount away from lastWord
    diffCount = 0;
    // if currentTag ==1, compare w/ label
    NSString* firstWordText = [firstWord text];
    NSString* firstFieldText = (NSString*)[aFields objectAtIndex:0];
    
    //NSString* textComp = [[NSString alloc] initWithString:text];
    NSLog(@"winTest - current text is %@",text);
    // text must equal previous word minus one letter
    
    UITextField* chosenField;
    // loop reversively through text fields
    for (int y=aFields.count ; y>0 ; y--)
    {
        NSLog(@"winTest - loop - field %i",y);
        chosenField = (UITextField*)[self.view viewWithTag:y+1];
        // if the text field has text
        if ([chosenField hasText] == YES)
        {
            NSLog(@"field has text");
            // if the text field's length equals the last word's length
            if ([[chosenField text ] length] == [[lastWord text] length])
            {
                NSLog(@"field's text length equals lastWord's text length");
                // loop through each letter in the words
                for (int i=0 ; i<[[chosenField text] length] ; i++)
                {
                    if ([[lastWord text] characterAtIndex:i] != [[chosenField text] characterAtIndex:i])
                        diffCount++;
                }
            }
            NSLog(@"breaking loop. diffCount is %i",diffCount);
            // after finding the text-containing field nearest the last word, break
            break;
        }
    }
    
    if (diffCount == 1)
    {
        // reset diffCount
        diffCount = 0;
        // check all words for any errors in word link
        
        // first word
        if ([firstFieldText length] == [firstWordText length])
        {
            for (int i=0 ; i<wordLength ; i++)
            {
                if ([firstWordText characterAtIndex:i] != [firstFieldText characterAtIndex:i])
                    diffCount++;
            }
            if (diffCount !=1)
                return NO;
        }
        
        
        // rest of the words
        //        for (int x=1 ; x<aFields.count ; x++)
        //        {
        //            if ([(UITextField*)[self.view viewWithTag:x+1] hasText] == YES)
        //            {
        //                if ([self wordLink:(NSString*)[aFields objectAtIndex:x] getPriorText:(NSString*)[aFields objectAtIndex:x-1] getField:nil] == NO)
        //                    return NO;
        //            }
        //        }
        
        return YES;
    }
    else
        return NO;
    
}

- (BOOL)isWord:(NSString*)text
{
    UITextChecker* checker = [[UITextChecker alloc] init];
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSRange checkerRange = [checker rangeOfMisspelledWordInString:[text lowercaseString] range:NSMakeRange(0,[text length]) startingAt:0 wrap:NO language: [currentLocale objectForKey:NSLocaleLanguageCode]];
    return checkerRange.location == NSNotFound;
}

- (BOOL)isEditing:(id)sender
{
    reEdit = YES;
    /*if (reEdit == YES)
    {
        NSLog(@"testfldshldrrn fxn run");
        [self textFieldShouldReturn:(UITextField*)[self.view viewWithTag:currentTag+1]];
    }*/
    
    // store current field's tag
    currentTag = [sender tag]-1;
    NSLog(@"aFields count is %i\nCurrent field is %i",aFields.count,currentTag);
    
    // return key disabled when text field is blank
    UITextField* currentField = (UITextField*)sender;
    [currentField setEnablesReturnKeyAutomatically:YES];
    
    for (int i=0 ; i<(tagIndex) ; i++)
    {
        if (i!=currentTag)
            [(UITextField*)[self.view viewWithTag:i+1] setEnabled:NO];
    }
    
    // if current field's tag < total number of fields, user is      RE-editing
    /*if (currentTag < aFields.count)
    {
        reEdit = YES;
        NSLog(@"user is reediting");
        // disable all other text fields - when reEditing only
        for (int i=0 ; i<(tagIndex) ; i++)
        {
            if (i!=currentTag)
                [(UITextField*)[self.view viewWithTag:i+1] setEnabled:NO];
        }
    }*/
    
    return YES;
}

- (void)linkAnimation
{
    // disable tap/swipe gestures and restart button
    [firstTap setEnabled:NO];
    [swipeDown setEnabled:NO];
    [restartB setEnabled:NO];
    
    // get best score
    NSInteger nBest = [self bestCalc];
    // update only if best is 0 or greater than plays
    
    if ((aFields.count < nBest) || nBest == 0)
    {
        // update best score, save to plist
        [scoresArray replaceObjectAtIndex:(LEVEL-1) withObject:[[NSString alloc] initWithFormat:@"%i",aFields.count]];
        [dictP writeToFile:path atomically:YES];
        [bestB setText:[[NSString alloc] initWithFormat:@"Best: %i",aFields.count]];
        [bestB setFont:[UIFont fontWithName:@"ChalkboardSE-Regular" size:17]];
        NSLog(@"new best score. check if file wrote. path data is: %@",[scoresArray objectAtIndex:(LEVEL-1)]);
    }
    
    // set up link animation
    [lastWord setAlpha:0];
    CGRect labelPos = lastWord.frame;
    labelPos.origin.x = firstWord.frame.origin.x;
    if (IS_IPHONE5)
        labelPos.origin.y = cPos+100;
    else
        labelPos.origin.y = cPos+175;
    lastWord.frame = labelPos;
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{lastWord.alpha=1.0;} completion:nil];
    [self performSelector:@selector(adCheck) withObject:nil afterDelay:1.0];
}

- (void)adCheck
{
    // will check whether to show ad or win screen
    [self showWin];
}

- (void)showAd
{
    // will show an ad
    // bring up modal view (hit "X" to pop view)
    NSLog(@"showing ad");
}

- (void)showWin
{
    // re-enable restart button
    [restartB setEnabled:YES];
    
    // when user reaches end of stage
    if (LEVEL == wordList.count)
    {
        // set win label text
        [winLabel setText:@"Stage Complete!"];
        
        // get prior view controller
        NSArray* aVC = [self.navigationController viewControllers];
        UITableViewController* priorVC = [aVC objectAtIndex:(aVC.count-2)];
        
        // check if user reached end of mix/categ. stages
        if ((nRow+1) == [priorVC tableView:priorVC.tableView numberOfRowsInSection:nSection])
        {
            // change next level button title
            [winNextB setTitle:@"Select Stage" forState:UIControlStateNormal];
            // reprogram it as back button
            [winNextB removeTarget:self action:@selector(arrowRight:) forControlEvents:UIControlEventTouchUpInside];
            [winNextB addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            [winNextB setTitle:@"Next Stage" forState:UIControlStateNormal]; // arrow right fxn handles the rest
    }
    
    // show win screen
    [winBackground setHidden:NO];
    [winLabel setHidden:NO];
    [winNextB setHidden:NO];
    [winAgainB setHidden:NO];
}

- (NSInteger)bestCalc
{
    NSMutableDictionary* scoreDict = [dictP objectForKey:@"Root"];
    // Get to appropriate level array!
    // if 4-letter words, will need an extra array for categories
    // set up variable for use in setWordLength fxn
    
    // access appropriate array based on word length
    NSString* sWordLength = [[NSString alloc] init];
    
    switch (wordLength)
    {
        case 3:
            sWordLength = @"ThreeLetters";
            break;
        case 4:
            sWordLength = @"FourLetters";
            break;
        case 5:
            sWordLength = @"FiveLetters";
    }
    NSLog(@"word length title is %@",sWordLength);
    NSMutableArray* stagesArray = [scoreDict objectForKey:sWordLength];
    
    if (wordLength == 4)
    {
        NSMutableArray* categoryArray = [stagesArray objectAtIndex:nSection];
        scoresArray = [categoryArray objectAtIndex:(nRow)];
        NSLog(@"word length is four. array of categories. count is %i. array of scores. count is %i",categoryArray.count,scoresArray.count);
    }
    else
    {
        scoresArray = [stagesArray objectAtIndex:(nRow)];
        NSLog(@"word length is not four. array of numbers. count is %i",scoresArray.count);
    }
    
    // define best score
    NSString* nBest = [[NSString alloc]initWithFormat:@"%@",[scoresArray objectAtIndex:(LEVEL-1)]];
    NSLog(@"best score is currently %i",nBest.integerValue);
    return nBest.integerValue;
}

- (void)setRowNumber:(int)row
{
    nRow = row;
}

- (void)setSecNumber:(int)section
{
    nSection = section;
}

- (void)hideWinScreen
{
    // hide the win screen items
    if (winNextB.isHidden == NO)
    {
        [winBackground setHidden:YES];
        [winLabel setHidden:YES];
        [winNextB setHidden:YES];
        [winAgainB setHidden:YES];
        
        // default tap/swipe settings
        [firstTap setEnabled:YES];
        [swipeDown setEnabled:YES];
        
    }
}

- (void)reset
{
    // clears level's text fields and data
    
    if (tagIndex < 1)
    {
        //NSLog(@"at the beginning!");
    }
    else
    {
        //NSLog(@"level restarted");
        
        // get current field's text
        UITextField* textField = (UITextField*)[self.view viewWithTag:tagIndex];
        // close kb
        [textField resignFirstResponder];
        
        for (int i=0 ; i<tagIndex ; i++)
        {
            // get current field's text
            UITextField* tField = (UITextField*)[self.view viewWithTag:i+1];
            
            // delete field
            [tField removeFromSuperview];
            
            // remove text from array
            acFields[i] = nil;
            
        }
        [aFields removeAllObjects];
        // reset variables to default
        tagIndex = 0;
        cPos = 0;
        error = NO;
        [firstTap setEnabled:YES];
        
        // reset lastWord's position
        lastWord.frame = lastWordRect;
        
        // update plays number
        NSString* playsText = [[NSString alloc] initWithFormat:@"Links: %i",0];
        [playsB setText:playsText];
        
        // default scroll settings
        [scroll setContentInset:UIEdgeInsetsMake(0,0,0,0)];
        
        // hide win screen items
        [self hideWinScreen];
    }
}

- (void)newLevel:(int)level
{
    // called after level 1
    if (level != 1)
        [self.view setNeedsDisplay];
    
    // set up variables
    LEVEL = level;
    aFields = [[NSMutableArray alloc] init ];
    [scroll addSubview:firstWord];
    [scroll addSubview:lastWord];
    green = [[UIColor alloc] initWithRed:0.8784 green:0.8 blue:0.11373 alpha:1];
    red = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:1];
    
    // don't let tap interfere with toolbar/navigational buttons
    firstTap.cancelsTouchesInView = NO;
    
    // call fxns to load new word and best score
    [self loadNewWord:LEVEL];
    [self setWordLength:wordLength];
    // level,new words, word length are all updated before bestCalc
    [bestB setText:[[NSString alloc] initWithFormat:@"Best: %i",[self bestCalc]]];
    
    // disable arrow keys if first or last level of the stage
    if (LEVEL == 1)
        [arrowLB setEnabled:NO];
    else
        [arrowLB setEnabled:YES];
    if (LEVEL == wordList.count)
        [arrowRB setEnabled:NO];
    else
        [arrowRB setEnabled:YES];
}

- (IBAction)arrowRight:(id)sender
{
    // hide win screen items
    [self hideWinScreen];
    
    // reload view with next level,words
    if (LEVEL != wordList.count)
    {
        // reset level
        [self reset];
        // increase level
        LEVEL+=1;
        //NSLog(@"arrowRight: level is now %i",LEVEL);
        [self newLevel:LEVEL];
    }
    else
    {
        // reset level
        [self reset];
        
        // get previous view controller
        NSArray* aVC = [self.navigationController viewControllers];
        UITableViewController* priorVC = [aVC objectAtIndex:(aVC.count-2)];
        // maintains correct order of view controllers on stack
        [self.navigationController popToViewController:priorVC animated:NO];
        //call previous view controller and select the next level
        [priorVC tableView:priorVC.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:(nRow+1) inSection:nSection]];
    }
}

- (IBAction)arrowLeft:(id)sender
{
    // hide win screen items
    [self hideWinScreen];
    
    // reload view with previous level,words
    if (LEVEL != 1)
    {
        // reset level
        [self reset];
        // increase level
        LEVEL-=1;
        [self newLevel:LEVEL];
    }
}

- (IBAction)goBack:(id)sender
{
    // hide win screen items
    [self hideWinScreen];
    
    // pop view
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restart:(id)sender
{
    [self reset];
}

- (IBAction)closeKb:(id)sender
{
    // get current field's text
    UITextField* textField = (UITextField*)[self.view viewWithTag:tagIndex];
    
    // if no text fields...
    if (tagIndex < 1)
    {
        //NSLog(@"no more text fields!");
    }
    // if text field has text that has not been stored in array...
    else if (textField.hasText == YES && reEdit == YES)
    {
        // call textFieldShouldReturn fxn
        kbId = 1;
        [self textFieldShouldReturn:textField];
    }
    // otherwise, text field is blank or contains a word already stored in array 
    else
    {
        NSLog(@"field deleted.");
        // delete field
        [textField removeFromSuperview];
        // reduce tagIndex by 1
        tagIndex--;
        // reduce cPos by 50
        cPos-=50;
        // close keyboard
        [textField resignFirstResponder];
        // enable tap
        [firstTap setEnabled:YES];
        
        // if textField has stored word...
        if (tagIndex != aFields.count)
        {
            NSLog(@"and removed from array");
            // remove from arrays
            [aFields removeObjectAtIndex:tagIndex];
            acFields[tagIndex] = nil;
            
            // update plays number
            NSString* playsText = [[NSString alloc] initWithFormat:@"Links: %i",aFields.count];
            [playsB setText:playsText];
            
            // if stored word was an error, reset
            error = NO;
        }
        if (!IS_IPHONE5)
        {
            // set scroll settings appropriately, based on screen size
            if (cPos > 50)
            {
                [scroll setContentInset:UIEdgeInsetsMake(0,0,cPos+450,0)];
                [scroll setContentOffset:CGPointMake(0,cPos-100) animated:YES];
            }
            if (cPos <= 50)
            {
                [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                [scroll setContentOffset:CGPointMake(0, 0)];
            }
        }
        if (IS_IPHONE5)
        {
            if (cPos > 50)
            {
                [scroll setContentInset:UIEdgeInsetsMake(0,0,cPos+50,0)];
                [scroll setContentOffset:CGPointMake(0,cPos-100) animated:YES];
            }
            if (cPos == 50)
            {
                [scroll setContentOffset:CGPointMake(0, cPos-50)];
                [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            if (cPos == 0)
            {
                [scroll setContentOffset:CGPointMake(0, 0)];
            }
        }
    }
}

- (void)createB
{
    // disable tap (keyboard is currently up)
    [firstTap setEnabled:NO];
    
    // NOTE: SEE OUTPUT - SOMETIMES BLANK FIELD RANDOMLY REACHED
    // loop to determine if blank field exists
    //NSString* blankString = [[NSString alloc] initWithString:@""];
    
    /*for (int i=0 ; i<(tagIndex) ; i++)
    {
        if ((acFields[i] == nil) || (strcmp(acFields[i],"") == 1))
        {
            blankField = YES;
            NSLog(@"blank field reached at box %i",i);
            break;
        }
    }*/
    //NSLog(@"loop %i,tag index %i, %s",i,tagIndex, aFields[tagIndex-1]);
    
    if (error == NO || tagIndex==0)
    {
        // increase tag for new text field
        tagIndex++;
        // increase position for new field
        cPos+=50;
        // create newWord
        UITextField *newWord = nil;
        newWord = [[UITextField alloc] init];
        // set its position and formatting
        [newWord setFrame:CGRectOffset([firstWord frame], 0, cPos)];
        newWord.textAlignment =UITextAlignmentCenter;
        newWord.borderStyle = UITextBorderStyleNone;
        UIFont* font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:30];
        [newWord setFont:font];        
        [newWord setKeyboardAppearance:UIKeyboardAppearanceAlert];
        // add the newWord to scroll view
        [scroll addSubview:newWord];
        [scroll sendSubviewToBack:newWord];
        // tag it
        newWord.tag = tagIndex;
        // autocapitalize
        [newWord setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
        // turn off autocorrect
        [newWord setAutocorrectionType:UITextAutocorrectionTypeNo];
        // run function when return hit
        [newWord addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
        // run function when editing
        [newWord addTarget:self action:@selector(isEditing:) forControlEvents:UIControlEventEditingDidBegin];
        // bring up keyboard
        [newWord becomeFirstResponder];
    }
    else
    {
        // there is a blank field, show Kb
        UITextField* currentTextField = (UITextField*)[self.view viewWithTag:currentTag+1];
        [currentTextField setKeyboardAppearance:UIKeyboardAppearanceAlert];
        [currentTextField becomeFirstResponder];
    }
    
    // format scroll to increase size if position is outside screen
    if (!IS_IPHONE5 && cPos > 100)
    {
        NSLog(@"not iphone5!");
        [scroll setContentInset:UIEdgeInsetsMake(0,0,cPos+350,0)];
        
        // scroll to current text field
        [scroll setContentOffset:CGPointMake(0,(currentTag*50)-50) animated:YES];
    }
    if (IS_IPHONE5 && cPos >150)
    {
        NSLog(@"iphone5");
        [scroll setContentInset:UIEdgeInsetsMake(0,0,cPos-50,0)];
        
        // scroll to current text field
        [scroll setContentOffset:CGPointMake(0,(currentTag*50)-100) animated:YES];
    }
    
    // return blankField,mistake to default
    blankField = NO;
    //NSLog(@"tagIndex is %i",tagIndex);
}

- (IBAction)nextB:(id)sender {
    // called by screen tap
    
    // get location of tap
    UITapGestureRecognizer* tapRecon = (UITapGestureRecognizer*)sender;
    CGPoint location = [tapRecon locationInView:scroll];
    
    // only call function if tap is in scroll view
    if (CGRectContainsPoint(scroll.bounds, location))
    {
        // create a new text field
        [self createB];
    }
}

@end
