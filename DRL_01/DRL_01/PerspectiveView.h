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
    Isgl3dMultiMaterialCube *_cube;
}

-(id) initWithCube:(Isgl3dMultiMaterialCube *)cube;
@end
