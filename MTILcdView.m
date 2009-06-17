//
//  MTILcdView.m
//  Copyright 2009 Ryan Morlok
//  http://softwareblog.morlok.net/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MTILcdView.h"

#define LCD_DRAWING_UNSCALED_HEIGHT			90.0
#define LCD_DRAWING_UNSCALED_WIDTH			50.0
#define LCD_DRAWING_BETWEEN_DIGIT_SPACE		10.0

// The elements of the LCD digit are numbered as follows:
//
//   /----3----\
//   |         |
//   2         4
//   |         |
//   \         /
//    ----7----
//   /         \
//   |         |
//   1         5
//   |         |
//   \----6----/
//
// The following constants translate these positions into a bitmask
#define LCD_POS_1	0x01
#define LCD_POS_2	0x02
#define LCD_POS_3	0x04
#define LCD_POS_4	0x08
#define LCD_POS_5	0x10
#define LCD_POS_6	0x20
#define LCD_POS_7	0x40

// Translates a character into a bitmask for the LCD elements
NSUInteger BitmaskForDigit(char c)
{
	switch (c) {
		case '0' : return LCD_POS_1 | LCD_POS_2 | LCD_POS_3 | LCD_POS_4 | LCD_POS_5 | LCD_POS_6;	
		case '1' : return LCD_POS_4 | LCD_POS_5;
		case '2' : return LCD_POS_3 | LCD_POS_4 | LCD_POS_7 | LCD_POS_1 | LCD_POS_6;
		case '3' : return LCD_POS_3 | LCD_POS_4 | LCD_POS_7 | LCD_POS_5 | LCD_POS_6;
		case '4' : return LCD_POS_2 | LCD_POS_7 | LCD_POS_4 | LCD_POS_5;
		case '5' : return LCD_POS_3 | LCD_POS_2 | LCD_POS_7 | LCD_POS_5 | LCD_POS_6;
		case '6' : return LCD_POS_3 | LCD_POS_2 | LCD_POS_7 | LCD_POS_1 | LCD_POS_6 | LCD_POS_5;
		case '7' : return LCD_POS_3 | LCD_POS_4 | LCD_POS_5;
		case '8' : return LCD_POS_1 | LCD_POS_2 | LCD_POS_3 | LCD_POS_4 | LCD_POS_5 | LCD_POS_6 | LCD_POS_7;
		case '9' : return LCD_POS_2 | LCD_POS_3 | LCD_POS_4 | LCD_POS_5 | LCD_POS_6 | LCD_POS_7;
		default  : return 0; 
	}
}

@implementation MTILcdView

#pragma mark Private Methods
- (void) drawColonToContext:(CGContextRef)context
{
	CGFloat size = 0.85 * LCD_DRAWING_BETWEEN_DIGIT_SPACE;
	
	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, litColor);
	CGContextAddEllipseInRect(context, CGRectMake((LCD_DRAWING_BETWEEN_DIGIT_SPACE - size)/2.0, 25.0 - (size/2.0), size, size));
	CGContextAddEllipseInRect(context, CGRectMake((LCD_DRAWING_BETWEEN_DIGIT_SPACE - size)/2.0, 65.0 - (size/2.0), size, size));
	CGContextFillPath(context);
	CGContextRestoreGState(context);
}

- (void) drawDigit:(NSUInteger)digitDef toContext:(CGContextRef)context
{
	CGContextSaveGState(context);
	
	CGMutablePathRef myPath = CGPathCreateMutable();
	CGPathMoveToPoint(myPath,    NULL,  5.0,  1.0);
	CGPathAddLineToPoint(myPath, NULL,  0.0,  6.0);
	CGPathAddLineToPoint(myPath, NULL,  0.0, 34.0);
	CGPathAddLineToPoint(myPath, NULL,  5.0, 39.0);
	CGPathAddLineToPoint(myPath, NULL, 10.0, 34.0);
	CGPathAddLineToPoint(myPath, NULL, 10.0,  6.0);
	CGPathCloseSubpath(myPath);
	
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_1 ? litColor : dimColor));
	CGContextTranslateCTM(context, 0.0, 5.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_2 ? litColor : dimColor));
	CGContextTranslateCTM(context, 0.0, 40.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_3 ? litColor : dimColor));
	CGContextTranslateCTM(context, 5.0, 45.0);
	CGContextRotateCTM(context, -pi / 2.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_4 ? litColor : dimColor));
	CGContextTranslateCTM(context, 5.0, 45.0);
	CGContextRotateCTM(context, -pi / 2.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_5 ? litColor : dimColor));
	CGContextTranslateCTM(context, 0.0, 40.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_6 ? litColor : dimColor));
	CGContextTranslateCTM(context, 5.0, 45.0);
	CGContextRotateCTM(context, -pi / 2.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, (digitDef & LCD_POS_7 ? litColor : dimColor));
	CGContextTranslateCTM(context, 40.0, 0.0);
	CGContextAddPath(context, myPath);
	CGContextFillPath(context);
	
	CGPathRelease(myPath);
	
	CGContextRestoreGState(context);
}


- (CGAffineTransform) scaleTranformForFrame
{
	// Compute how much we should scale our drawing based on the 
	// needed height versus the height that is available.
	CGFloat scale = [self bounds].size.height  / LCD_DRAWING_UNSCALED_HEIGHT;
	return CGAffineTransformMakeScale(scale, scale);
}

#pragma mark Public Methods

@synthesize litColor;
@synthesize dimColor;
@synthesize text;

- (void) setLitColor:(CGColorRef)color
{
	if( color == litColor )
		return;
	
	CGColorRelease(litColor);
	
	litColor = CGColorRetain(color);
	
	[self setNeedsDisplay:YES];
}

- (void) setDimColor:(CGColorRef)color
{
	if( color == dimColor )
		return;
	
	CGColorRelease(dimColor);
	
	dimColor = CGColorRetain(color);
	
	[self setNeedsDisplay:YES];
}

- (void) setText:(NSString*)t
{
	if( text == t )
		return;
	
	[text release];
	text = [t retain];
	
	[self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Nothing to see here...
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	// Scale the drawing for the current size of the view
	CGContextConcatCTM(myContext, [self scaleTranformForFrame]);
	
	// Draw the digits
	for(NSUInteger i = 0; i < text.length; i++) {
		if( ':' == [text characterAtIndex:i] ) {
			// Colon is special case that fits in the normal space between two numbers
			CGContextSaveGState(myContext);
			
			if( i > 0 ) 
				CGContextTranslateCTM(myContext, LCD_DRAWING_UNSCALED_WIDTH, 0);
			
			[self drawColonToContext:myContext];
			
			CGContextRestoreGState(myContext);
		} else {
			if( i > 0 ) 
				CGContextTranslateCTM(myContext, LCD_DRAWING_UNSCALED_WIDTH + LCD_DRAWING_BETWEEN_DIGIT_SPACE, 0);
				
			[self drawDigit:BitmaskForDigit([text characterAtIndex:i]) toContext:myContext];
		}
	}
}

- (void)dealloc
{
	[text release];
	CGColorRelease(litColor);
	CGColorRelease(dimColor);

	text = nil;
	litColor = NULL;
	dimColor = NULL;
	
	[super dealloc];
}
@end
