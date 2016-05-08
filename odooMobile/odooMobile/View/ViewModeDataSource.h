//
//  ViewModeDataSource.h
//

#import <UIKit/UIKit.h>
#import "OdooData.h"
#import "GlobalModels.h"

@interface ViewModeDataSource : NSObject {
    WindowData* _window;
    ViewModeData* _viewMode;
    
    CGFloat _updateWidth;
    __weak id _updatedTarget;
    SEL _updatedAtion;
}

-(instancetype) initWithWindow:(WindowData*)window;

-(void) updateHeightWithWidth:(CGFloat)width updatedTarget:(id)target andAction:(SEL)action;

-(void) requestMoreRecords;

-(void) cleanRecord;
-(NSInteger) numberOfRecords;
-(CGFloat) heightOfRecord:(NSInteger)index;
-(UITableViewCell*) cellOfRecord:(NSInteger)index inTableView:(UITableView*)tableView;

-(void) callUpdate:(NSNumber*)index;

@end
