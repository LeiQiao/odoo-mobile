//
//  KanbanDataSource.m
//

#import "KanbanDataSource.h"

@implementation KanbanDataSource

-(instancetype) initWithWindow:(WindowData*)window
{
    if( self = [super initWithWindow:window] )
    {
        for( ViewModeData* viewMode in _window.viewModes )
        {
            if( [viewMode.name isEqualToString:@"kanban"] )
            {
                _viewMode = viewMode;
                break;
            }
        }
    }
    return self;
}

@end
