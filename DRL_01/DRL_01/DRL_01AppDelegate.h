//
//  DRL_01AppDelegate.h
//  DRL_01
//
//  Created by Matthew Arbesfeld on 2/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

@class Isgl3dViewController;

@interface DRL_01AppDelegate : NSObject <UIApplicationDelegate> {

@private
	Isgl3dViewController * _viewController;
	UIWindow * _window;
}

@property (nonatomic, retain) UIWindow * window;

@end
