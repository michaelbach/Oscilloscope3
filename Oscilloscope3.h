/* Oscilloscope3 */

#import <Cocoa/Cocoa.h>

#define kOscilloscope2MaxNumberOfTraces 8

//	History
//	=======
//
//	2013-02-06	now used the new "CGColor" method for much easier conversion between NS- and CG-Colour -- gets rid of a memory leak to boot
//	2012-08-21	added conditional ARC compilation
//  2012-04-12  corrected inconsequential typo, dropped the colorspace argument
//	2012-03-22	a number of asthetic improvements, also added setTraceToCGFloatArray & zero lines, some properties renamed
//	2012-02-28	used "CGContextAddLines", should speed up
//	2012-02-20	defected from Cocoa to Quartz graphics (CoreGrafics)
//	2011-01-26	added lineWidth
//	2010-03-21	renamed and extended "fullscale", general code cleanup
//	2010-03-03	in "advanceWithSamples:" test if "numberOfTraces" is correct, else set. Same for "setTrace:"
//	2010-02-24	added gray dividing lines between traces
//	2010-02-23	lots of recent changes, today added decimation in "setTrace"
//	2009-12-30	added @property


@interface Oscilloscope3 : NSView {
	NSUInteger numberOfPoints, numberOfTraces, maxNumberOfTraces;
	CGFloat width, height, fullscale, lineWidth;
	NSColor *backgroundColor, *ySeparatorColor, *yZeroLinesColor;
	BOOL isTraceZeroTop, isShiftTraces, isDrawYZeroLines, isDrawYSeparators;
}


- (void) advanceWithSample: (CGFloat) sampleValue;				// also switches to single channel mode
- (void) advanceWithSamples: (NSArray *) sampleArrayOfNumbers;	// also switches multichannel mode with the correct number of traces
- (void) setTraceToSweep: (NSArray *) sweep;					// also switches to single channel mode
- (void) setTraceToCGFloatArray: (CGFloat *)sweep nSamples: (NSUInteger) nSamples;	// single channel with a C-array of CGFloats
- (void) setTrace: (NSUInteger)iTrace toSweep:(NSArray*)sweep;	// also switches multichannel mode; adjusts numberOfTraces if necessary
- (void) setTrace: (NSUInteger)iTrace toCGFloatArray: (CGFloat *)sweep nSamples: (NSUInteger) nSamples;	// multichannel with a C-array of CGFloats

@property	(readwrite)	CGFloat fullscale;						// since we're bipolar: ± this value
@property	(readonly)	NSUInteger numberOfPoints;				// width of the corresponding view in device points
@property	(readwrite)	NSUInteger numberOfTraces;				// multichannel; number of traces
@property	(readonly)	NSUInteger maxNumberOfTraces;			// multichannel; maximal possible number of traces

@property	(readonly)	CGFloat width, height;					// view dimensions
- (void)	setColor: (NSColor *) color;						// switches to single channel mode. Default: dark blue.
- (void)	setColor: (NSColor *) color forTrace: (NSUInteger) iTrace;// multichannel; there are 7 predefined colors
#if !__has_feature(objc_arc)
@property	(retain)	NSColor *backgroundColor;				// default: very light grey
@property	(retain)	NSColor *ySeparatorColor;				// default: grey
@property	(retain)	NSColor *yZeroLinesColor;				// default: grey
#else
@property	(strong)	NSColor *backgroundColor;				// default: very light grey
@property	(strong)	NSColor *ySeparatorColor;				// default: grey
@property	(strong)	NSColor *yZeroLinesColor;				// default: grey
#endif
@property	(readwrite) CGFloat lineWidth;						// the pensize for the traces
@property	(readwrite) BOOL isTraceZeroTop;					// trace ordering: trace zero is on top, or on bottom
@property	(readwrite)	BOOL isShiftTraces;						// if YES: traces are moving, new values at right. Else just replacing
@property	(readwrite)	BOOL isDrawYZeroLines;					// if YES: add y-zero lines
@property	(readwrite)	BOOL isDrawYSeparators;					// if YES: add y-separator lines


@end
