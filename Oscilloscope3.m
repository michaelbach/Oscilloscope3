// http://maccoder.blogspot.com/2007/02/nssavepanel-in-objective-c.html

#import "Oscilloscope3.h"


@implementation Oscilloscope3;


static NSMutableArray  *traceColors, *allTraces; // has maxChannels objects, each is a mutable array of samples
static CGContextRef cgc;
CGColorSpaceRef colorSpace;
#define kNumPointsMax1 2000
static CGPoint cgPointsArray[kNumPointsMax1];


//#define max(x,y) ((x) > (y)) ? (x) : (y)
#define min(x,y) ((x) > (y)) ? (y) : (x)


static CGColorRef cgColorCreateFromNSColor(CGColorSpaceRef inColorSpace, NSColor *color) {
	NSColor *deviceColor = [color colorUsingColorSpaceName: NSDeviceRGBColorSpace];
	CGFloat components[4];
	[deviceColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
	return CGColorCreate(inColorSpace, components);
}



- (id) initWithFrame:(NSRect)frameRect {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ((self = [super initWithFrame: frameRect]) != nil) {
		width = frameRect.size.width;  height = frameRect.size.height;
		[self setIsTraceZeroTop: YES];
		[self setFullscale: 3.0f];
		numberOfPoints = (NSUInteger) round(width);
		maxNumberOfTraces = kOscilloscope2MaxNumberOfTraces;
		[self setNumberOfTraces: 2];
		[self setIsShiftTraces: YES];
		[self setLineWidth: 1.0f];
		allTraces = [[NSMutableArray arrayWithCapacity: maxNumberOfTraces] retain];
		for (NSUInteger iTrace=0; iTrace<maxNumberOfTraces; ++iTrace) 
			[allTraces addObject: [NSMutableArray arrayWithCapacity: numberOfPoints]];
		for (NSMutableArray *aTrace in allTraces)	// initialise all traces to 0.0
			for (NSUInteger i=0; i<numberOfPoints; ++i) [aTrace addObject: [NSNumber numberWithFloat:0.0f]];
		[self setBackgroundColor: [NSColor colorWithDeviceWhite: 0.9f alpha: 1.0f]];
		[self setSeparatorColor: [NSColor grayColor]];
		traceColors = [[NSMutableArray arrayWithCapacity: maxNumberOfTraces] retain];
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.667 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Blau
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.250 saturation: 1.0 brightness: 0.5 alpha: 1.0]];	// dunkles Grün
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.000 saturation: 1.0 brightness: 0.7 alpha: 1.0]];	// dunkles Rot
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.500 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Cyan
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.833 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Magenta
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.125 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Gelb

		colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		//NSLog(@"Oscilloscope>init2");
	}
	return self;
}


- (BOOL) isOpaque {return YES;}


- (void) drawRect:(NSRect)aRect {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	height = aRect.size.height; // so resizing works at least vertically
	
	cgc = [[NSGraphicsContext currentContext] graphicsPort];
	CGColorRef col = cgColorCreateFromNSColor(colorSpace, backgroundColor);
	CGContextSetFillColorWithColor(cgc, col);
	CGContextFillRect(cgc, NSRectToCGRect(aRect));  // first fill the background
	CGColorRelease(col);
	
	NSUInteger numPnts = [[allTraces objectAtIndex: 0] count];
	for (NSUInteger iTrace = 1; iTrace < numberOfTraces; ++iTrace) { // draw trace separator lines
		CGFloat y = ((isTraceZeroTop) ? (numberOfTraces-iTrace) : (iTrace)) * height / numberOfTraces;
		CGPoint twoPoints[] = {CGPointMake(0, y), CGPointMake(numPnts, y)};
		col = cgColorCreateFromNSColor(colorSpace, separatorColor);
		CGContextSetStrokeColorWithColor(cgc, col);
		CGContextBeginPath(cgc);
		CGContextAddLines(cgc, twoPoints, 2);
		CGContextStrokePath(cgc);
		CGColorRelease(col);
	}

	for (NSUInteger iTrace = 0; iTrace < numberOfTraces; ++iTrace) { // now draw the traces
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		CGContextSetLineWidth(cgc, self.lineWidth);
		CGFloat yTrace = (isTraceZeroTop) ? (numberOfTraces-iTrace-0.5) : (iTrace+0.5);
		CGContextBeginPath(cgc);
		col = cgColorCreateFromNSColor(colorSpace, [traceColors objectAtIndex: (iTrace % traceColors.count)]);
		CGContextSetStrokeColorWithColor(cgc, col);
		
		if (numPnts < kNumPointsMax1) {
			for (NSUInteger iSample=0; iSample < numPnts; ++iSample) {
				cgPointsArray[iSample].y = (yTrace + [[aTrace objectAtIndex: iSample] floatValue]/2.0/fullscale) * height / numberOfTraces;
				cgPointsArray[iSample].x = iSample;
			}
			CGContextAddLines(cgc, cgPointsArray, numPnts);
		} else {
			for (NSUInteger iSample=0; iSample < numPnts; ++iSample) {
				CGFloat y = (yTrace + [[aTrace objectAtIndex: iSample] floatValue]/2.0/fullscale) * height / numberOfTraces;
				if (iSample == 0) CGContextMoveToPoint(cgc, 0, y);
				else CGContextAddLineToPoint(cgc, iSample, y);
			}
		}
		CGContextStrokePath(cgc);
		CGColorRelease(col);
	}
//	NSLog(@"%u", [self numberOfTraces]);
//	NSLog(@"%f", [[[allTraces objectAtIndex: 0] objectAtIndex:0] floatValue]);
}


- (void) advanceWithSample: (CGFloat) sampleValue {	// single channel
	[self setNumberOfTraces: 1];
	[self advanceWithSamples: [NSArray arrayWithObject: [NSNumber numberWithFloat: sampleValue]]];
}

- (void) advanceWithSamples: (NSArray *) sampleArray {		// multichannel
	static NSUInteger sampleIndex = 0;  sampleIndex = (sampleIndex+1) % numberOfPoints;
	NSUInteger nTraces = min(maxNumberOfTraces, sampleArray.count);
	if (nTraces != numberOfTraces) numberOfTraces = nTraces;
	for (NSUInteger iTrace = 0; iTrace < nTraces; ++iTrace) {
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		if (isShiftTraces) {
			[aTrace removeObjectAtIndex: 0];  [aTrace addObject: [sampleArray objectAtIndex: iTrace]];
		} else {
			[aTrace replaceObjectAtIndex: sampleIndex withObject: [sampleArray objectAtIndex: iTrace]];
		}
	}
	[self setNeedsDisplay: YES];
//	NSLog(@"%f", [[sampleArray objectAtIndex:0] floatValue]);
//	NSLog(@"%f", [[[allTraces objectAtIndex: 0] objectAtIndex:10] floatValue]);
}


- (void) setTraceToSweep: (NSArray *) sweep {	// single channel
	[self setNumberOfTraces: 1];  [self setTrace: 0 toSweep: sweep];
}

- (void) setTrace: (NSUInteger) iTrace toSweep: (NSArray *) sweep {	// multichannel
	if (iTrace >= maxNumberOfTraces) return;
	if (iTrace >= numberOfTraces) [self setNumberOfTraces: iTrace+1];
	NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
	while (sweep.count > numberOfPoints) {	// while the sweep is longer than the trace, we decimate by 2 until it fits
		NSMutableArray *a = [NSMutableArray arrayWithCapacity:sweep.count/2];
		for (NSUInteger i = 0; i<sweep.count/2; ++i) [a addObject:[NSNumber numberWithFloat: 0.5*([[sweep objectAtIndex:i*2] floatValue] + [[sweep objectAtIndex:i*2+1] floatValue])]];
		sweep = [NSArray arrayWithArray: a];
	}
	NSNumber *aNAN = [NSNumber numberWithFloat:NAN];
	for (NSUInteger iSmpl=0; iSmpl<numberOfPoints; ++iSmpl)
		[aTrace replaceObjectAtIndex:iSmpl withObject: ((iSmpl < sweep.count) ? [sweep objectAtIndex:iSmpl] : aNAN)];
	[self setNeedsDisplay:YES];
}


- (void) setTrace: (NSUInteger)iTrace toCGFloatArray: (CGFloat *)sweep nSamples: (NSUInteger) nSamples {	//NSLog(@"setTrace:toCGFloatArray, n=%u", nSamples);
	if (iTrace >= maxNumberOfTraces) return;
	if (iTrace >= numberOfTraces) [self setNumberOfTraces: iTrace+1];
	if (nSamples > 2000) nSamples = 2000;
	NSMutableArray* channelArray = [NSMutableArray arrayWithCapacity: nSamples];
	CGFloat* ptr = sweep;
	for (NSUInteger iSample=0; iSample<nSamples; ++iSample) {
		[channelArray addObject: [NSNumber numberWithFloat: *ptr]];  ptr += sizeof(CGFloat);
	}
	[allTraces replaceObjectAtIndex: iTrace withObject: channelArray];
	[self setNeedsDisplay:YES];
}


- (void) setColor: (NSColor *) color {
	numberOfTraces = 1;  [traceColors replaceObjectAtIndex: 0 withObject: color];
}
- (void) setColor: (NSColor *) color forTrace: (NSUInteger) iTrace {
	if (iTrace > maxNumberOfTraces) return;
	[traceColors replaceObjectAtIndex: iTrace withObject: color];
}


@synthesize isTraceZeroTop;

@synthesize maxNumberOfTraces;

- (NSUInteger) numberOfTraces {return numberOfTraces;};
- (void) setNumberOfTraces:(NSUInteger) n {
	numberOfTraces = (n > maxNumberOfTraces) ? maxNumberOfTraces : n;
}

@synthesize	numberOfPoints;
@synthesize	fullscale;
@synthesize width;
@synthesize height;
@synthesize backgroundColor;
@synthesize separatorColor;
@synthesize isShiftTraces;
@synthesize lineWidth;

@end
