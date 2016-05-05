//
//  ViewModeDataSource.h
//

#import <UIKit/UIKit.h>
#import "OdooData.h"

typedef void(^ViewModeRequestCallback)(BOOL success);

@interface ViewModeDataSource : NSObject {
    WindowData* _window;
    ViewModeData* _viewMode;
    
    NSMutableArray* _recordHeights;
}

@property(nonatomic) ViewModeRequestCallback callback;

-(instancetype) initWithWindow:(WindowData*)window;

-(void) requestMoreRecords;

-(void) cleanRecord;
-(NSInteger) numberOfRecords;
-(CGFloat) heightOfRecord:(NSInteger)index;
-(UITableViewCell*) cellOfRecord:(NSInteger)index;

@end
