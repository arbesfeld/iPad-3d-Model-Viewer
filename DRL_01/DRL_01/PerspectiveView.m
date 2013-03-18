//
//  HelloWorldView.m
//  DRL_01
//
//  Created by Matthew Arbesfeld on 2/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveView.h"
#import "MasterView.h"

@implementation PerspectiveView

- (id) init {
	
	if ((self = [super init])) {
	}
	return self;
}

//init with cube, camera and name
- (id) initWithCube:(Isgl3dMultiMaterialCube *)cube {
    
    if ((self = [super init])) {
        _cube = cube;
        
        // Add the cube to the scene.
        [self.scene addChild:_cube];
        
        // Schedule updates
        [self schedule:@selector(tick:)];
    }
    return self;
}
- (void) dealloc {
    
	if (_cube) {
		[_cube release];
	}
	[super dealloc];
}


- (void) tick:(float)dt {
}
@end

