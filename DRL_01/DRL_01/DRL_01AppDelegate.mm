//
//  DRL_01AppDelegate.h
//  DRL_01
//
//  Created by Matthew Arbesfeld on 2/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "DRL_01AppDelegate.h"
#import "Isgl3dViewController.h"
#import "MasterView.h"
#import "Isgl3d.h"

@implementation DRL_01AppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(UIApplication*)application {

	// Create the UIWindow
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	NSLog(@"Debug");
	// Instantiate the Isgl3dDirector and set background color
	[Isgl3dDirector sharedInstance].backgroundColorString = @"919191"; 

	// Set the device orientation
	[Isgl3dDirector sharedInstance].deviceOrientation = Isgl3dOrientationLandscapeLeft;

	// Set the director to display the FPS
	[Isgl3dDirector sharedInstance].displayFPS = YES;

	// Create the UIViewController
	_viewController = [[Isgl3dViewController alloc] initWithNibName:nil bundle:nil];
	_viewController.wantsFullScreenLayout = YES;
	
	// Create OpenGL view (here for OpenGL ES 1.1)
	Isgl3dEAGLView * glView = [Isgl3dEAGLView viewWithFrameForES1:[_window bounds]];

	// Set view in director
	[Isgl3dDirector sharedInstance].openGLView = glView;
	
	// Specify auto-rotation strategy if required (for example via the UIViewController and only landscape)
	//[Isgl3dDirector sharedInstance].autoRotationStrategy = Isgl3dAutoRotationByUIViewController;
	[Isgl3dDirector sharedInstance].allowedAutoRotations = Isgl3dAllowedAutoRotationsLandscapeOnly;
	
	// Enable retina display : uncomment if desired
//	[[Isgl3dDirector sharedInstance] enableRetinaDisplay:YES];

	// Enables anti aliasing (MSAA) : uncomment if desired (note may not be available on all devices and can have performance cost)
//	[Isgl3dDirector sharedInstance].antiAliasingEnabled = YES;
	
	// Set the animation frame rate
	[[Isgl3dDirector sharedInstance] setAnimationInterval:1.0/60];
    
	// Add the OpenGL view to the view controller
	_viewController.view = glView;

	// Add view to window and make visible
	[_window addSubview:_viewController.view];
	[_window makeKeyAndVisible];

    [[MasterView alloc] init];
    
//	// Creates the view(s) and adds them to the director
//	[[Isgl3dDirector sharedInstance] addView:[PerspectiveView view]];
//	
//	// Run the director
//	[[Isgl3dDirector sharedInstance] run];
}

- (void) dealloc {
	if (_viewController) {
		[_viewController release];
	}
	if (_window) {
		[_window release];
	}
	
	[super dealloc];
}

- (void) applicationWillResignActive:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] pause];
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] resume];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] stopAnimation];
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] startAnimation];
}

- (void) applicationWillTerminate:(UIApplication *)application {
	// Remove the OpenGL view from the view controller
	[[Isgl3dDirector sharedInstance].openGLView removeFromSuperview];
	
	// End and reset the director	
	[Isgl3dDirector resetInstance];
	
	// Release
	[_viewController release];
	_viewController = nil;
	[_window release];
	_window = nil;
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] onMemoryWarning];
}

- (void) applicationSignificantTimeChange:(UIApplication *)application {
	[[Isgl3dDirector sharedInstance] onSignificantTimeChange];
}

@end
