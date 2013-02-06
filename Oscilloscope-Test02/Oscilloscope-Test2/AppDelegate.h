//
//  AppDelegate.h
//  Oscilloscope-Test2
//
//  Created by Michael Bach on 28.02.12.
//  Copyright (c) 2012 Department of Ophthalmology, University Medical Center Freiburg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Oscilloscope3.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet Oscilloscope3 *osci;	
	IBOutlet NSPopUpButton *numberOfChannels_outlet;
	IBOutlet NSColorWell *colorBackg_outlet, *colorSeparators_outlet, *colorYZeroLines_outlet;
}


- (IBAction) numberOfChannels_action: (id) sender;
- (IBAction) movingCheckBox_action: (id) sender;

- (IBAction) separatorsCheckBox_action: (id) sender;
- (IBAction) colorSeparators_action: (id) sender;

- (IBAction) yZeroCheckBox_action: (id) sender;
- (IBAction) colorYZeroLines_action: (id) sender;

- (IBAction) colorBackg_action: (id) sender;


@property (weak) IBOutlet NSWindow *window;

@end
