//
//  GameController.h
//  WordLinkProto
//
//  Created by B McCowan on 4/23/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameController : UIViewController
{
    __weak IBOutlet UILabel *firstWord;
    __weak IBOutlet UILabel *lastWord;
    __weak IBOutlet UIView *view;
    __weak IBOutlet UIScrollView *scroll;
    
    IBOutlet UILabel *playsB; // label that shows number of words played on the current level
    IBOutlet UILabel *bestB; // label that shows best score on the current level
    IBOutlet UITapGestureRecognizer *firstTap; // brings up keyboard for editing a text field
    IBOutlet UISwipeGestureRecognizer *swipeDown; // closes keyboard
    IBOutlet UINavigationItem *navItem; // holds bar buttons
    IBOutlet UIBarButtonItem *backB; // back button - navi bar
    IBOutlet UIBarButtonItem *restartB; // restart - navi bar
    IBOutlet UIToolbar *toolbar;
    UIBarButtonItem *arrowRB; // next puzzle
    UIBarButtonItem *arrowLB; // previous puzzle
    
    NSMutableArray* aFields; // stores text field data (makes data retrieval easier)
    NSArray* wordList; // plist contents passed from level controller
    NSString* path; // plist filename
    NSMutableDictionary* dictP; // stores plist
    int nRow; // stores row passed from letter controller
    int nSection; // stores section passed from 4-letter level controller
    NSMutableArray* scoresArray; // stores score data
    int LEVEL; // keeps track of current level
    int wordLength; // stores word length (used in setWordLength)
    const char* acFields[500]; // stores textField data too (makes comparisons easier)
    int kbId; // keyboardId - used in closeKb and textFieldShouldReturn
    int cPos; // position of a new text field
    int tagIndex; // keeps track of total number of tags
    int currentTag; // tells the current field's tag
    bool blankField; // tells if current field is blank or not
    bool reEdit; // tells if user is reediting a field (used in isEditing)
    bool error; // tells if an incorrect word exists (used in createB)
    int errorPos; // tells incorrect word's position
    int diffCount; // counts number of different letters in two words (wordLink,winTest)
    CGRect lastWordRect; // stored rect (used in reset)
    UIColor* green; // color of correct words
    UIColor* red; // color of incorrect words
    
    IBOutlet UIImageView *winBackground; // background for win screen
    IBOutlet UILabel *winLabel; // level complete label
    IBOutlet UIButton *winNextB; // next level button
    IBOutlet UIButton *winAgainB; // play again/remove ads button
}

- (NSInteger)bestCalc; // best score calc
- (void)linkAnimation; // shown after level completion
- (void)setRowNumber:(int)row;
- (void)setSecNumber:(int)section;
- (void)setWordLength:(int)length;
- (void)loadWordList:(NSArray*)list;
- (void)loadNewWord:(int)lvl;
- (BOOL)isWord:(NSString*)text;
- (BOOL)winTest:(NSString*)text
       getField:(UITextField*)textField;
- (BOOL)wordLink:(NSString*)text
    getPriorText:(NSString*)priorText
        getField:(UITextField*)textField;
- (BOOL)wordCheck:(NSString*)text;
- (void)createB;
- (void)newLevel:(int)level;
- (void)reset; // used by restart fxn and newLevel
- (void)hideWinScreen;

- (void)adCheck; // called upon win
- (void)showAd; // shows an ad
- (void)showWin; // shows win screen

- (IBAction)arrowRight:(id)sender;
- (IBAction)arrowLeft:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)restart:(id)sender; // restart button press
- (IBAction)nextB:(id)sender;
- (IBAction)closeKb:(id)sender;
@end
