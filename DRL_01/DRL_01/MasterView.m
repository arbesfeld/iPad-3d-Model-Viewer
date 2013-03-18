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
        
//        Isgl3dTextureMaterial * cubeMaterial = [[Isgl3dTextureMaterial alloc] initWithTextureFile:@"cubeMaterial.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:YES repeatY:YES];
        
        Isgl3dColorMaterial * cubeMaterial1 = [Isgl3dColorMaterial materialWithHexColors:@"6f1717" diffuse:@"6f1717" specular:@"6f1717" shininess:0];
        
        Isgl3dColorMaterial * cubeMaterial2 = [Isgl3dColorMaterial materialWithHexColors:@"53a4c6" diffuse:@"53a4c6" specular:@"53a4c6" shininess:0];
        
        Isgl3dColorMaterial * cubeMaterial3 = [Isgl3dColorMaterial materialWithHexColors:@"399618" diffuse:@"399618" specular:@"399618" shininess:0];
        Isgl3dUVMap * uvMapCube = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:0.0 vB:0.0 uC:1.0 vC:1.0];
        
        NSArray * cubeMaterialArray = [[NSArray alloc] initWithObjects:cubeMaterial1, cubeMaterial2, cubeMaterial3, cubeMaterial1, cubeMaterial2, cubeMaterial3, nil];
        NSArray * uvMapCubeArray = [[NSArray alloc] initWithObjects:uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube, uvMapCube,  nil];
        _cube = [Isgl3dMultiMaterialCube cubeWithDimensionsAndMaterials:cubeMaterialArray uvMapArray:uvMapCubeArray width:3 height:3 depth:3 nSegmentWidth:2 nSegmentHeight:2 nSegmentDepth:2];
        
        // lower right
        _perspectiveView = [[PerspectiveView alloc] initWithCube:_cube];
        
        //create perspective grid
        Isgl3dTextureMaterial * gridMaterial = [Isgl3dTextureMaterial materialWithTextureFile:@"grid.png" shininess:0 precision:Isgl3dTexturePrecisionHigh repeatX:YES repeatY:YES];

        Isgl3dUVMap * uvMap = [Isgl3dUVMap uvMapWithUA:0.0 vA:0.0 uB:2.0 vB:0.0 uC:0.0 vC:2.0];
        Isgl3dPlane * grid = [Isgl3dPlane meshWithGeometryAndUVMap:20.0 height:20.0 nx:2 ny:2 uvMap:uvMap];
         
        Isgl3dMeshNode * gridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:grid andMaterial:gridMaterial];
        gridNode.rotationX = -90;
        gridNode.position = iv3(0, 0, 0);
        gridNode.alphaCullValue = 0.1;
        [_perspectiveView.scene addChild:gridNode];
        
        _perspectiveView.viewport = CGRectMake(0.0, 0.0, width/2.0, height/2.0);
        _perspectiveController = [[PerspectiveController alloc] initWithView:_perspectiveView cx:30 cy:30 cz:30  name:@"Perspective" cube:_cube];
        
        // lower left
        _frontView = [[PerspectiveView alloc] initWithCube:_cube];
        _frontView.viewport = CGRectMake(0.0, height/2.0, width/2.0, height/2.0);
        _frontController = [[PerspectiveController alloc] initWithView:_frontView cx:0 cy:0 cz:30 name:@"Front" cube:_cube];
        
        Isgl3dMeshNode * frontGridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:grid andMaterial:gridMaterial];
        
        frontGridNode.position = iv3(0, 0, 0);
        frontGridNode.alphaCullValue = 0.1;
        [_frontView.scene addChild:frontGridNode];
        
        // upper right
        _sideView = [[PerspectiveView alloc] initWithCube:_cube];
        _sideView.viewport = CGRectMake(width/2.0, 0.0, width/2.0, height/2.0);
        _sideController = [[PerspectiveController alloc] initWithView:_sideView cx:30 cy:0 cz:0 name:@"Side" cube:_cube];
        
        Isgl3dMeshNode * sideGridNode = [[[Isgl3dMeshNode alloc] init] createNodeWithMesh:grid andMaterial:gridMaterial];
        sideGridNode.rotationX = -90;
        sideGridNode.rotationZ = -90;
        sideGridNode.position = iv3(0, 0, 0);
        sideGridNode.alphaCullValue = 0.1;
        [_sideView.scene addChild:sideGridNode];
        
        // upper left
        _topView = [[PerspectiveView alloc] initWithCube:_cube];
        _topView.viewport = CGRectMake(width/2.0, height/2.0, width/2.0, height/2.0);
        _topController = [[PerspectiveController alloc] initWithView:_topView cx:0 cy:30 cz:epsilon name:@"Top" cube:_cube];
        
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
- (void) rotateButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Rotate button pressed");
	if(_canRotate) {
        [_rotateButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"rotateOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setRotation:NO];
        [_topController setRotation:NO];
        [_sideController setRotation:NO];
        [_frontController setRotation:NO];
        _canRotate = NO;
    }
    else {
        [_rotateButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"rotateOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setRotation:YES];
        [_topController setRotation:YES];
        [_sideController setRotation:YES];
        [_frontController setRotation:YES];
        _canRotate = YES;
    }
}

- (void) moveButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Move button pressed");
	if(_canMove) {
        [_moveButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"moveOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:NO];
        [_topController setMove:NO];
        [_sideController setMove:NO];
        [_frontController setMove:NO];
        _canMove = NO;
    }
    else {
        [_moveButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"moveOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:YES];
        [_topController setMove:YES];
        [_sideController setMove:YES];
        [_frontController setMove:YES];
        _canMove = YES;
    }
}

- (void) scaleButtonPressed:(Isgl3dEvent3D *)event {
	NSLog(@"Scale button pressed");
	if(_canScale) {
        [_scaleButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"resizeOff.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setScale:NO];
        [_topController setScale:NO];
        [_sideController setScale:NO];
        [_frontController setScale:NO];
        _canScale = NO;
    }
    else {
        [_scaleButton setMaterial:[Isgl3dTextureMaterial materialWithTextureFile:@"resizeOn.png" shininess:0 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO]];
        [_perspectiveController setMove:YES];
        [_topController setScale:YES];
        [_sideController setScale:YES];
        [_frontController setScale:YES];
        _canScale = YES;
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
    
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_perspectiveController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_frontController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_sideController];
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_topController];
	[super dealloc];
}

@end
