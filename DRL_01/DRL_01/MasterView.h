//
//  MasterView.h
//  DRL_01
//
//  Created by mata on 2/21/13.
//
//

#import "isgl3d.h"

#import "PerspectiveView.h"
#import "PerspectiveController.h"

@interface MasterView : NSObject {
    
@private
    Isgl3dMultiMaterialCube *_cube;
    PerspectiveController *_perspectiveController, *_topController, *_frontController, *_sideController;
    Isgl3dBasic3DView *_perspectiveView, *_topView, *_frontView, *_sideView;
    Isgl3dBasic2DView *_hud, *_staticHud;
    Isgl3dTextureMaterial * _rotateButtonMaterial, * _moveButtonMaterial, * _scaleButtonMaterial;
    Isgl3dGLUIButton * _rotateButton, * _moveButton, * _scaleButton;
    
    NSMutableArray *_worldObjects;
    
    BOOL _canRotate, _canMove, _canScale;
}
@end
