//
// Class:    ENUnderlinedButton
//
// Project:	 ElectionNigeria
//
// Date:     27/03/14
//
// Author:	 Vikas Kumar 
//


#import "ENUnderlinedButton.h"

@implementation ENUnderlinedButton

+(ENUnderlinedButton*)underlinedButton
{
    ENUnderlinedButton* button = [[ENUnderlinedButton alloc] init];
    return button;
}


- (void) drawRect:(CGRect)rect
{
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + 2);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + 2);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}

@end
