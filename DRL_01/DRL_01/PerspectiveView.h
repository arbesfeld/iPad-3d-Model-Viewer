//
//  PerspectiveView.h
//  DRL_01
//
//  Created by mata on 2/21/13.
//
//

#import "isgl3d.h"


@interface PerspectiveView : Isgl3dBasic3DView {
    
@private
    //list of all cubes
    NSMutableArray *_allCubes;
    //cube that is being modified
    Isgl3dMultiMaterialCube *_cube;
    Isgl3dLight *_greenLight, *_redLight, *_blueLight;
}
-(id) initWithCube:(Isgl3dMultiMaterialCube *)cube andTick:(BOOL)tick;

- (void)tick:(float)dt;
@end
