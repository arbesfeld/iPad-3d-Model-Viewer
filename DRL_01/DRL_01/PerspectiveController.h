//
//  PerspectiveController.h
//  DRL_01
//
//  Created by mata on 2/27/13.
//
//

#import "isgl3d.h"
#import "PerspectiveView.h"
@interface PerspectiveController : NSObject <Isgl3dTouchScreenResponder> {
    
@private
    Isgl3dCamera * _camera;
    Isgl3dView * _view;
    
    Isgl3dMultiMaterialCube * _cube;
    
    Isgl3dVector3 *worldPoints;
    
    CGRect _viewRect;
    CGPoint _initCenter;
    
    Isgl3dNode * _target;
    NSString * _name;
    
    BOOL _xMovable, _yMovable, _zMovable;
    BOOL _currentlyTouched;
    
    BOOL _canRotate, _canMove, _canScale;
}

- (id) initWithView:(Isgl3dView *)view cx:(float)cx cy:(float)cy cz:(float)cz name:(NSString *)name cube:(Isgl3dMultiMaterialCube *)cube world:(NSMutableArray *)worldObjects;
- (void) setRotation:(BOOL)rotate;
- (void) setMove:(BOOL)move;
- (void) setScale:(BOOL)scale;

@end
