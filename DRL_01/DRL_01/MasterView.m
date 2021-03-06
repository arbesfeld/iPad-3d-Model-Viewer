//
//  MasterView.m
//  DRL_01
//
//  Created by mata on 2/21/13.
//
//

#import "MasterView.h"

#import "PerspectiveView.h"
#import "PerspectiveController.h"

float const epsilon = 1e-8;
@implementation MasterView

- (id) init {
    if ((self = [super init])) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        [self createWorld];
        
        // hud
        _canRotate = NO; _canMove = YES; _canScale = NO;
        
        _staticHud = [[Isgl3dBasic2DView alloc] init];
        Isgl3dTextureMaterial * hudImageMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"hudPic.png" shininess:0 precision:Isgl3dTexturePrecisionHigh repeatX:NO repeatY:NO];
        Isgl3dGLUIImage * hudImage = [[Isgl3dGLUIImage alloc] initWithMaterial:hudImageMaterial width:1024 height:1025];
        [hudImage setX:-15 andY:-300];
        
        [_staticHud.scene addChild:hudImage];
        
        _hud = [[Isgl3dBasic2DView alloc] init];
        _rotateButtonMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"rotateOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
        _rotateButton = [[Isgl3dGLUIButton alloc] initWithMaterial:_rotateButtonMaterial width:70 height:70];
        [_rotateButton setX:height/2-30 andY:width/2 - 45];
		[_rotateButton addEvent3DListener:self method:@selector(rotateButtonPressed:) forEventType:TOUCH_EVENT];
        [_hud.scene addChild:_rotateButton];
        
        _moveButtonMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"moveOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
        _moveButton = [[Isgl3dGLUIButton alloc] initWithMaterial:_moveButtonMaterial width:70 height:70];
        [_moveButton setX:height/2 - 85 andY:width/2 - 45];
		[_moveButton addEvent3DListener:self method:@selector(moveButtonPressed:) forEventType:TOUCH_EVENT];
        _moveButton.scaleX = 1.5;
        _moveButton.scaleY = 1.5;
        [_hud.scene addChild:_moveButton];
        
        _scaleButtonMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"resizeOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
        _scaleButton = [[Isgl3dGLUIButton alloc] initWithMaterial:_scaleButtonMaterial width:70 height:70];
        [_scaleButton setX:height/2 + 35 andY:width/2 - 45];
        _scaleButton.scaleX = 0.9;
        _scaleButton.scaleY = 0.9;
		[_scaleButton addEvent3DListener:self method:@selector(scaleButtonPressed:) forEventType:TOUCH_EVENT];
        [_hud.scene addChild:_scaleButton];
        
        [_hud.scene addChild:hudImage];
        
        // cube
        
//        Isgl3dTextureMaterial * cubeMaterial = [[Isgl3dTextureMaterial alloc] initWithTextureFile:@"cubeMaterial.png" shininess:0     precision:Isgl3dTexturePrecisionMedium repeatX:YES repeatY:YES];
        
        Isgl3dColorMaterial * cubeMaterial1 = [Isgl3dColorMaterial materialWithHexColors:@"6f1717" diffuse:@"6f1717" specular:@"6f1717" shininess:0];
        
        Isgl3dColorMaterial * cubeMaterial2 = [Isgl3dColorMaterial materialWithHexColors:@"53a4c6" diffuse:@"53a4c6" specular:@"53a4c6" shininess:0];
        
        Isgl3dColorMaterial * cubeMaterial3 = [Isgl3dColorMaterial materialWithHexColors:@"399618" diffuse:@"399618" specular:@"399618" shininess:0];
        Isgl3dUVMap * uvMapCube = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:0.0 vB:0.0 uC:1.0 vC:1.0];
        
        NSArray * cubeMaterialArray = [[NSArray alloc] initWithObjects:cubeMaterial1, cubeMaterial2, cubeMaterial3, cubeMaterial1, cubeMaterial2, cubeMaterial3, nil];
        NSArray * uvMapCubeArray = [[NSArray alloc] initWithObjects:uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube,  nil];
        _cube = [Isgl3dMultiMaterialCube cubeWithDimensionsAndMaterials:cubeMaterialArray uvMapArray:uvMapCubeArray width:1 height:1 depth:1 nSegmentWidth:2 nSegmentHeight:2 nSegmentDepth:2];
        _cube.scaleX = 3;
        _cube.scaleY = 3;
        _cube.scaleZ = 3;
        
        //create perspective grid
        Isgl3dTextureMaterial * gridMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"grid.png" shininess:0 precision:Isgl3dTexturePrecisionHigh repeatX:YES repeatY:YES];
        
        Isgl3dUVMap * uvMap = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:2.0 vB:0.0 uC:0.0 vC:2.0];
        Isgl3dPlane * grid = [Isgl3dPlane meshWithGeometryAndUVMap:20.0 height:20.0 nx:2 ny:2 uvMap:uvMap];
        
        Isgl3dMeshNode * gridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:grid andMaterial:gridMaterial];
        gridNode.rotationX = -90;
        gridNode.position = iv3(0, 0, 0);
        [gridNode enableAlphaCullingWithValue:0.1];
        // lower right
        _perspectiveView = [[PerspectiveView alloc] initWithCube:_cube andWorld:_worldObjects andTick:YES];
        
        [_perspectiveView.scene addChild:gridNode];
        
        _perspectiveView.viewport = CGRectMake(0.0, 0.0, width/2.0, height/2.0);
        _perspectiveController = [[PerspectiveController alloc] initWithView:_perspectiveView cx:30 cy:30 cz:30  name:@"Perspective" cube:_cube world:_worldObjects];
        
        // lower left
        _frontView = [[PerspectiveView alloc] initWithCube:_cube andWorld:_worldObjects andTick:NO];
        _frontView.viewport = CGRectMake(0.0, height/2.0, width/2.0, height/2.0);
        _frontController = [[PerspectiveController alloc] initWithView:_frontView cx:0 cy:0 cz:30 name:@"Front" cube:_cube world:_worldObjects];
        
        Isgl3dCube *frontGridMesh = [[Isgl3dCube alloc] initWithGeometry:10 height:0.2 depth:10 nx:1 ny:1];
        Isgl3dMeshNode * frontGridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:frontGridMesh andMaterial:gridMaterial];
        frontGridNode.position = iv3(0, 0, 0);
        //frontGridNode.alphaCullValue = 0.1;
        [_frontView.scene addChild:frontGridNode];
        
        // upper right
        _sideView = [[PerspectiveView alloc] initWithCube:_cube andWorld:_worldObjects andTick:NO];
        _sideView.viewport = CGRectMake(width/2.0, 0.0, width/2.0, height/2.0);
        _sideController = [[PerspectiveController alloc] initWithView:_sideView cx:30 cy:0 cz:0 name:@"Side" cube:_cube world:_worldObjects];
        
        Isgl3dCube *sideGridMesh = [[Isgl3dCube alloc] initWithGeometry:10 height:0.2 depth:10 nx:1 ny:1];
        Isgl3dMeshNode * sideGridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:sideGridMesh andMaterial:gridMaterial];
        //sideGridNode.rotationX = -90;
        //sideGridNode.rotationZ = -90;
        sideGridNode.position = iv3(0, 0, 0);
        //sideGridNode.alphaCullValue = 0.1;
        [_sideView.scene addChild:sideGridNode];
        
        // upper left
        _topView = [[PerspectiveView alloc] initWithCube:_cube andWorld:_worldObjects andTick:YES];
        _topView.viewport = CGRectMake(width/2.0, height/2.0, width/2.0, height/2.0);
        _topController = [[PerspectiveController alloc] initWithView:_topView cx:0 cy:30 cz:epsilon name:@"Top" cube:_cube world:_worldObjects];
        
        [_topView.scene addChild:gridNode];
        
        // Add views to touch-screen manager
        [[Isgl3dTouchScreen sharedInstance] addResponder:_perspectiveController];
        [[Isgl3dTouchScreen sharedInstance] addResponder:_frontController];
        [[Isgl3dTouchScreen sharedInstance] addResponder:_sideController];
        [[Isgl3dTouchScreen sharedInstance] addResponder:_topController];
        
        [[Isgl3dDirector sharedInstance] addView:_staticHud];
        
        [[Isgl3dDirector sharedInstance] addView:_hud];
        
        // Run the director
        [[Isgl3dDirector sharedInstance] run];
        
		return self;
	}
	return self;
}

- (void) createWorld {
    // hard code in some objects
    
    Isgl3dColorMaterial * worldMaterial = [Isgl3dColorMaterial materialWithHexColors:@"701820" diffuse:@"701820" specular:@"701820" shininess:0];
    Isgl3dUVMap * uvMapCube = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:0.0 vB:0.0 uC:1.0 vC:1.0];
    
    NSArray * worldMaterialArray = [[NSArray alloc] initWithObjects:worldMaterial, worldMaterial, worldMaterial, worldMaterial, worldMaterial, worldMaterial, nil];
    NSArray * uvMapCubeArray = [[NSArray alloc] initWithObjects:uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube,  nil];
    
    Isgl3dMultiMaterialCube *object1 = [Isgl3dMultiMaterialCube cubeWithDimensionsAndMaterials:worldMaterialArray uvMapArray:uvMapCubeArray width:1 height:1 depth:1 nSegmentWidth:1 nSegmentHeight:1 nSegmentDepth:1];
    object1.scaleX = 1;
    object1.scaleY = 5;
    object1.scaleZ = 10;
    object1.position = iv3(7, 0, -3);
    object1.alpha = 0.3;
    [object1 setAlpha:200];
    [object1 setAlphaCullValue:0.1];
   // [object1 ]
    _worldObjects = [[NSMutableArray alloc] initWithObjects:object1, nil];
}

- (void) toggleRotate:(BOOL)on {
    if(on) {
        [_rotateButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"rotateOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setRotation:YES];
        [_topController setRotation:YES];
        [_sideController setRotation:YES];
        [_frontController setRotation:YES];
        _canRotate = YES;
    }
    else {
        [_rotateButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"rotateOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setRotation:NO];
        [_topController setRotation:NO];
        [_sideController setRotation:NO];
        [_frontController setRotation:NO];
        _canRotate = NO;
    }
}
- (void) toggleMove:(BOOL)on {
    if(on) {
        [_moveButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"moveOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:YES];
        [_topController setMove:YES];
        [_sideController setMove:YES];
        [_frontController setMove:YES];
        _canMove = YES;
    }
    else {
        [_moveButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"moveOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:NO];
        [_topController setMove:NO];
        [_sideController setMove:NO];
        [_frontController setMove:NO];
        _canMove = NO;
    }
}

- (void) toggleScale:(BOOL)on {
    if(on) {
        [_scaleButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"resizeOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:YES];
        [_topController setScale:YES];
        [_sideController setScale:YES];
        [_frontController setScale:YES];
        _canScale = YES;
    }
    else {
        [_scaleButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"resizeOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setScale:NO];
        [_topController setScale:NO];
        [_sideController setScale:NO];
        [_frontController setScale:NO];
        _canScale = NO;
    }
}
- (void) rotateButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Rotate button pressed");
	if(_canRotate) {
        [self toggleRotate:NO];
    }
    else {
        [self toggleRotate:YES];
        [self toggleMove:NO];
        [self toggleScale:NO];
    }
}

- (void) moveButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Move button pressed");
	if(_canMove) {
        [self toggleMove:NO];
    }
    else {
        [self toggleMove: YES];
        [self toggleRotate: NO];
        [self toggleScale: NO];
    }
}

- (void) scaleButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Scale button pressed");
	if(_canScale) {
        [self toggleScale:NO];
    }
    else {
        [self toggleScale:YES];
        [self toggleRotate:NO];
        [self toggleMove:NO]; 
    }
}

- (void) dealloc {
	if (_hud) {
		[_hud release];
	}
	if (_cube) {
		[_cube release];
	}
	if (_topView) {
		[_topView release];
	}
	if (_perspectiveView) {
		[_perspectiveView release];
	}
	if (_frontView) {
		[_frontView release];
	}
	if (_sideView) {
		[_sideView release];
	}
    if (_topController) {
		[_topController release];
	}
	if (_perspectiveController) {
		[_perspectiveController release];
	}
	if (_frontController) {
		[_frontController release];
	}
	if (_sideController) {
		[_sideController release];
	}
    if (_worldObjects) {
        [_worldObjects release];
    }
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_perspectiveController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_frontController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_sideController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_topController];
	[super dealloc];
}

@end
