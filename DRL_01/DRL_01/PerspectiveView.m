//
//  HelloWorldView.m
//  DRL_01
//
//  Created by Matthew Arbesfeld on 2/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveView.h"
#import "MasterView.h"

const float INTERSECTION_THRESHOLD = 0.4;
const int MAXCUBES = 20;

@implementation PerspectiveView

@synthesize worldObjects = _worldObjects;

- (id) init {
	
	if ((self = [super init])) {
	}
	return self;
}

//init with cube, camera and name
-(id) initWithCube:(Isgl3dMultiMaterialCube *)cube andWorld:(NSMutableArray *)worldObjects andTick:(BOOL)tick{
    
    if ((self = [super init])) {
        _cube = cube;
        _worldObjects = worldObjects;
        cubeCount = 0;
        [self.scene addChild:_cube];
        for(Isgl3dMultiMaterialCube *worldObject in worldObjects) {
            [self.scene addChild:worldObject];
        }
        
        // Create red light (producing white specular light), with rendering, and add to scene
        _redLight = [Isgl3dLight lightWithHexColor:@"FF0000" diffuseColor:@"FF0000" specularColor:@"FFFFFF" attenuation:0.02];
        _redLight.renderLight = YES;
        [self.scene addChild:_redLight];
        
        // Create green light (producing white specular light), with rendering, and add to scene
        _greenLight = [Isgl3dLight lightWithHexColor:@"00FF00" diffuseColor:@"00FF00" specularColor:@"FFFFFF" attenuation:0.02];
        _greenLight.renderLight = YES;
        [self.scene addChild:_greenLight];
        
        // Create blue light (producing white specular light), with rendering, and add to scene
        _blueLight = [Isgl3dLight lightWithHexColor:@"0000FF" diffuseColor:@"0000FF" specularColor:@"FFFFFF" attenuation:0.02];
        _blueLight.renderLight = YES;
        [self.scene addChild:_blueLight];
        
        // Set the scene ambient color
        [self setSceneAmbient:@"444444"];
        
        if(tick) {
            _allCubes = [[NSMutableArray alloc] initWithCapacity:500];
            [self addCube:cube];
            // Schedule updates
            [self schedule:@selector(tick:)];
        }
    }
    return self;
}
- (void) addCube:(Isgl3dMultiMaterialCube *)cube {
    Isgl3dColorMaterial * cubeMaterialGrey = [Isgl3dColorMaterial material];
    float grey = (200.0 - abs( (cubeCount * 20) % 246 - 123 ) ) / 255.0f;
    float greyArray[] = {grey, grey, grey};
    [cubeMaterialGrey setAmbientColor:greyArray];
    [cubeMaterialGrey setDiffuseColor:greyArray];
    [cubeMaterialGrey setSpecularColor:greyArray];
    
    Isgl3dUVMap * uvMapCube = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:0.0 vB:0.0 uC:1.0 vC:1.0];
    
    NSArray * cubeMaterialArray = [[NSArray alloc] initWithObjects:cubeMaterialGrey, cubeMaterialGrey, cubeMaterialGrey, cubeMaterialGrey, cubeMaterialGrey, cubeMaterialGrey, nil];
    NSArray * uvMapCubeArray = [[NSArray alloc] initWithObjects:uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube,  nil];
    
    Isgl3dMultiMaterialCube *staticCube = [Isgl3dMultiMaterialCube cubeWithDimensionsAndMaterials:cubeMaterialArray uvMapArray:uvMapCubeArray width:1 height:1 depth:1 nSegmentWidth:1 nSegmentHeight:1 nSegmentDepth:1];
    staticCube.x = cube.x;
    staticCube.y = cube.y;
    staticCube.z = cube.z;
    staticCube.scaleX = cube.scaleX;
    staticCube.scaleY = cube.scaleY;
    staticCube.scaleZ = cube.scaleZ;
    staticCube.rotationZ = cube.rotationZ;
    
    cubeCount++;
    [_allCubes addObject:staticCube];
    if([_allCubes count] > MAXCUBES) {
        [self.scene removeChild:[_allCubes objectAtIndex:0]];
        [_allCubes removeObjectAtIndex:0];
    }
    [self.scene addChild:[_allCubes lastObject]];
}

- (void) dealloc {
	if (_cube) {
		[_cube release];
	}
    if (_allCubes) {
        [_allCubes release];
    }
	[super dealloc];
}

- (float)intersectionPercentageCube1:(Isgl3dMultiMaterialCube *)cube1 withCube2:(Isgl3dMultiMaterialCube *)cube2 {
    float volumeCube1 = cube1.scaleX * cube1.scaleY * cube1.scaleZ;
    float volumeCube2 = cube2.scaleX * cube2.scaleY * cube2.scaleZ;
    
    Isgl3dVector3 cube1Lo = iv3(cube1.x - cube1.scaleX / 2,
                                cube1.y - cube1.scaleY / 2,
                                cube1.z - cube1.scaleZ / 2);
    Isgl3dVector3 cube1Hi = iv3(cube1.x + cube1.scaleX / 2,
                                cube1.y + cube1.scaleY / 2,
                                cube1.z + cube1.scaleZ / 2);
    
    Isgl3dVector3 cube2Lo = iv3(cube2.x - cube2.scaleX / 2,
                                cube2.y - cube2.scaleY / 2,
                                cube2.z - cube2.scaleZ / 2);
    Isgl3dVector3 cube2Hi = iv3(cube2.x + cube2.scaleX / 2,
                                cube2.y + cube2.scaleY / 2,
                                cube2.z + cube2.scaleZ / 2);
    float xDist = MIN(cube1Hi.x, cube2Hi.x) - MAX(cube1Lo.x, cube2Lo.x);
    float yDist = MIN(cube1Hi.y, cube2Hi.y) - MAX(cube1Lo.y, cube2Lo.y);
    float zDist = MIN(cube1Hi.z, cube2Hi.z) - MAX(cube1Lo.z, cube2Lo.z);
    //NSLog(@"%f %f %f", xDist, yDist, zDist);
    float volumeIntersection = xDist * yDist * zDist;
    if(volumeIntersection < 0)
        volumeIntersection = -volumeIntersection;
    //NSLog(@"volumeIntersection: %f", volumeIntersection);
    //NSLog(@"volumeCube1: %f", volumeCube1);
    
    return volumeIntersection / MAX(volumeCube1, volumeCube2);
}

- (void) tick:(float)dt {
    float intersectionPercentage = [self intersectionPercentageCube1:[_allCubes lastObject] withCube2:_cube];
    if(intersectionPercentage < INTERSECTION_THRESHOLD) {
        
        NSLog(@"New cube created");
        [self addCube:_cube];
    }
}
@end

