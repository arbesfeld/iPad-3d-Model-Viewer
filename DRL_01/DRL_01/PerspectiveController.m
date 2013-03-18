//
//  PerspectiveController.m
//  DRL_01
//
//  Created by mata on 2/27/13.
//
//

#import "PerspectiveController.h"
@interface PerspectiveController()
- (void) reset;
- (float) distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
@end


@implementation PerspectiveController

- (id) initWithView:(Isgl3dView *)view cx:(float)cx cy:(float)cy cz:(float)cz name:(NSString *)name cube:(Isgl3dMultiMaterialCube *)cube{
	
    if ((self = [super init])) {
        _view = [view retain];
        _viewRect = _view.viewport;
        _viewRect.origin.y = abs(_view.viewport.origin.y - [UIScreen mainScreen].bounds.size.height / 2);
        
        _camera = [view.camera retain];
        _name = [name retain];
        _cube = [cube retain];
        [_camera setPosition:iv3(cx, cy, cz)];
        
        _canMove = YES;
        _canScale = NO;
        _canRotate = NO;
        if(cx > 1) {
            _xMovable = NO;
        } else {
            _xMovable = YES;
        }
        if(cy > 1) {
            _yMovable = NO;
        } else {
            _yMovable = YES;
        }
        if(cz > 1) {
            _zMovable = NO;
        } else {
            _zMovable = YES;
        }
        _currentlyTouched = NO;
        
        [[Isgl3dDirector sharedInstance] addView:_view];
        
        
        
		// Initialise the controller
		[self reset];
    }
	
    return self;
}

- (void) dealloc {
	[_camera release];
	[_view release];
	[_name release];
    [_cube release];
	if (_target) {
		[_target release];
	}
    
	[super dealloc];
}

- (void) reset {
	
	
	// Release the target if it exists and reset camera look-at
	if (_target) {
		[_target release];
		_target = nil;
		
		[_camera lookAt:0 y:0 z:0];
	}
	
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    
    if(!CGRectContainsPoint(_viewRect, touchPoint)) {
        _currentlyTouched = NO;
        return;
    } else {
        _currentlyTouched = YES;
        NSLog(@"Touched in: %@", _name);
    }
	// Test for touches if no 3D object has been touched
	if (![Isgl3dDirector sharedInstance].objectTouched && ![Isgl3dDirector sharedInstance].isPaused) {
		
		NSEnumerator * enumerator = [touches objectEnumerator];
		UITouch * touch1 = [enumerator nextObject];
		
		if ([touches count] == 1) {
		} else if ([touches count] == 2) {
			UITouch * touch2 = [enumerator nextObject];
			
			CGPoint	location1 = [_view convertUIPointToView:[touch1 locationInView:touch1.view]];
			CGPoint	location2 = [_view convertUIPointToView:[touch2 locationInView:touch2.view]];
            
            _initCenter = [self averageBetweenPoint1:location1 andPoint2:location2];
        }
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// Do nothing
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_currentlyTouched) {
        return;
    }
	if (![Isgl3dDirector sharedInstance].isPaused) {
		NSEnumerator * enumerator = [touches objectEnumerator];
		UITouch * touch1 = [enumerator nextObject];
        
		// For single touch event: set the camera velocities...
		if ([touches count] == 1) {
			CGPoint	location = [_view convertUIPointToView:[touch1 locationInView:touch1.view]];
			CGPoint	previousLocation = [_view convertUIPointToView:[touch1 previousLocationInView:touch1.view]];
			
			if(!_canMove && !_canScale && !_canRotate) {
              [self panWithLoc1:previousLocation loc2:location];  
            }
            if(_canMove) {
                [self moveCubeWithLoc1:previousLocation loc2:location];
            }
            // ... for double touch, modify the orbital distance of the camera
		} else if ([touches count] == 2) {
			UITouch * touch2 = [enumerator nextObject];
			
			CGPoint	location1 = [_view convertUIPointToView:[touch1 locationInView:touch1.view]];
			CGPoint	previousLocation1 = [_view convertUIPointToView:[touch1 previousLocationInView:touch1.view]];
			CGPoint	location2 = [_view convertUIPointToView:[touch2 locationInView:touch2.view]];
			CGPoint	previousLocation2 = [_view convertUIPointToView:[touch2 previousLocationInView:touch2.view]];
			
            float rotateAmt = 0.0;
            if(!_canMove && !_canRotate && !_canScale) {
                [self scaleCamWithinitialLoc1:previousLocation1 initialLoc2:previousLocation2 finalLoc1:location1 finalLoc2:location2];
            }
            if(_canRotate) {
                rotateAmt = [self rotateCubeWithInitialCenter:_initCenter initialLoc1:previousLocation1 initialLoc2:previousLocation2 finalLoc1:location1 finalLoc2:location2];
            }
            if (_canScale && abs(rotateAmt) < 0.15) {
                [self scaleCubeWithInitialLoc1:previousLocation1 initialLoc2:previousLocation2 finalLoc1:location1 finalLoc2:location2];
            }
		}
	}
}

- (void) panWithLoc1:(CGPoint)loc1 loc2:(CGPoint)loc2 {
    Isgl3dVector3 pos = _camera.position;
    float panFactor = 0.03;
    if(_xMovable && _yMovable) { // front view
        pos.x += -(loc2.x - loc1.x) * panFactor;
        pos.y += -(loc2.y - loc1.y) * panFactor;
        
        [_camera lookAt:pos.x y:pos.y z:0];
    } else if(_xMovable && _zMovable) { // top view
        pos.x += -(loc2.x - loc1.x) * panFactor;
        pos.z += (loc2.y - loc1.y) * panFactor;
        NSLog(@"Pos.x: %f, pos.z: %f", pos.x, pos.z);
        [_camera setUpX:0 y:0 z:-10];
        [_camera lookAt:pos.x+0.1 y:0.00001 z:pos.z];
    } else if(_yMovable && _zMovable) { //side view
        pos.y += -(loc2.y - loc1.y) * panFactor;
        pos.z += (loc2.x - loc1.x) * panFactor;
        
        [_camera lookAt:0 y:pos.y z:pos.z];
    }
    [_camera setPosition:pos];
    
}
- (void) scaleCamWithinitialLoc1:(CGPoint)initLoc1 initialLoc2:(CGPoint)initLoc2
                       finalLoc1:(CGPoint)finalLoc1 finalLoc2:(CGPoint)finalLoc2 {
    float initDistance = [self distanceBetweenPoint1:initLoc1 andPoint2:initLoc2];
    float finalDistance = [self distanceBetweenPoint1:finalLoc1 andPoint2:finalLoc2];
    float scaleAmt = -(finalDistance - initDistance) / 10;
    
    Isgl3dVector3 pos = _camera.position;
    
    if(_xMovable && _yMovable) { // front view
        pos.z += scaleAmt;
        [_camera lookAt:pos.x y:pos.y z:0];
    } else if(_xMovable && _zMovable) { // top view
        pos.y += scaleAmt;
        [_camera lookAt:pos.x+0.1 y:0.00001 z:pos.z];
    } else if(_yMovable && _zMovable) { //side view
        pos.x += scaleAmt;
        [_camera lookAt:0 y:pos.y z:pos.z];
    } else {
        pos.x += scaleAmt;
        pos.y += scaleAmt;
        pos.z += scaleAmt;
    }
    [_camera setPosition:pos];
}

- (void) moveCubeWithLoc1:(CGPoint)loc1 loc2:(CGPoint)loc2 {
    Isgl3dVector3 pos = _cube.position;
    float panFactor = 0.03;
    
    if(_xMovable && _yMovable) { // front view
        pos.x += (loc2.x - loc1.x) * panFactor;
        pos.y += (loc2.y - loc1.y) * panFactor;
        
    } else if(_xMovable && _zMovable) { // top view
        pos.x += (loc2.x - loc1.x) * panFactor;
        pos.z += -(loc2.y - loc1.y) * panFactor;
        
    } else if(_yMovable && _zMovable) { //side view
        pos.y += (loc2.y - loc1.y) * panFactor;
        pos.z += -(loc2.x - loc1.x) * panFactor;
    }
    _cube.position = pos;
}

- (void) scaleCubeWithInitialLoc1:(CGPoint)initLoc1 initialLoc2:(CGPoint)initLoc2
finalLoc1:(CGPoint)finalLoc1 finalLoc2:(CGPoint)finalLoc2 {
    float initDistance = [self distanceBetweenPoint1:initLoc1 andPoint2:initLoc2];
    float finalDistance = [self distanceBetweenPoint1:finalLoc1 andPoint2:finalLoc2];
    float scaleAmt = (finalDistance - initDistance) / 1000;
    
    //scale proportional based on initial touches
    float xAmt = abs(initLoc1.x - finalLoc1.x) + abs(initLoc2.x - finalLoc2.x);
    float yAmt = abs(initLoc1.y - finalLoc1.y) + abs(initLoc2.y - finalLoc2.y);
    
    //make sure that scale is not less than 0.1
    if(_xMovable && _yMovable) { // front view
        _cube.scaleX = MAX(0.1, _cube.scaleX + scaleAmt * xAmt);
        _cube.scaleY = MAX(0.1, _cube.scaleY + scaleAmt * yAmt);
        
    } else if(_xMovable && _zMovable) { // top view
        _cube.scaleX = MAX(0.1, _cube.scaleX + scaleAmt * xAmt);
        _cube.scaleZ = MAX(0.1, _cube.scaleZ + scaleAmt * yAmt);
        
    } else if(_yMovable && _zMovable) { //side view
        _cube.scaleZ = MAX(0.1, _cube.scaleZ + scaleAmt * xAmt);
        _cube.scaleY = MAX(0.1, _cube.scaleY + scaleAmt * yAmt);
    }
}

- (float) rotateCubeWithInitialCenter:(CGPoint)initCenter initialLoc1:(CGPoint)initLoc1 initialLoc2:(CGPoint)initLoc2
                          finalLoc1:(CGPoint)finalLoc1 finalLoc2:(CGPoint)finalLoc2 {
    float initAngle = [self angleBetweenPoint1:initCenter andPoint2:initLoc1] +
                      [self angleBetweenPoint1:initCenter andPoint2:initLoc2];
    float finalAngle = [self angleBetweenPoint1:initCenter andPoint2:finalLoc1] +
                       [self angleBetweenPoint1:initCenter andPoint2:finalLoc2];
    float rotateAmt = (finalAngle - initAngle) * 30;
    
    
    NSLog(@"InitAngle: %f FinalAngle: %f RotateAmt: %f", initAngle, finalAngle, rotateAmt);
    //make sure that scale is not less than 0.1
    if(_xMovable && _yMovable) { // front view
        _cube.rotationZ += rotateAmt;
        
    } else if(_xMovable && _zMovable) { // top view
        _cube.rotationY += rotateAmt;
        
    } else if(_yMovable && _zMovable) { //side view
        _cube.rotationX += rotateAmt;
    }
    return rotateAmt;
}

- (void) setRotation:(BOOL)rotate {
    _canRotate = rotate;
}
- (void) setMove:(BOOL)move {
    _canMove = move;
}
- (void) setScale:(BOOL)scale {
    _canScale = scale;
}

/**
 * Calculate the distance between two CGPoints
 */
- (float) distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
	float dx = point1.x - point2.x;
	float dy = point1.y - point2.y;
	
	return sqrt(dx*dx + dy*dy);
}

- (float) angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return atan2(point2.y - point1.y, point2.x - point1.x);
}
- (float) manhattanDistanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return abs(point1.x - point2.x) + abs(point1.y - point2.y);
}
- (CGPoint) averageBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    return CGPointMake((point1.x + point2.x) / 2.0, (point1.y + point2.y) / 2.0);
}

@end
