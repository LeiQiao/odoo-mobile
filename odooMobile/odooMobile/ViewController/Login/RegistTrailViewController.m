//
//  RegistTrailViewController.m
//

#import "RegistTrailViewController.h"

@implementation RegistTrailViewController

#pragma mark
#pragma mark button events

-(IBAction) emailMe:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://leiqiaotalk@hotmail.com"]];
}

@end
