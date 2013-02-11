Oscilloscope3
=============

A simple multi-channel "oscilloscope" for MacOS. 


This oscilloscope can have one or up to kOscilloscopeMaxNumberOfTraces traces (preset to 8).
Most calls are availabe in both single- and multichannel mode.
 
The oscilloscope advances 1 point in device space per call (advanceWithSample(s))

Entire sweeps can also be displayed with setTrace:toSweep: / setSingleTraceToSweep:

0 is in the vertical center, the vertical scaling is addressed by calling setMaxPositiveValue:.
 

To insert in your program
-------------------------
* In your controller class: 
create an Oscilloscope2* IBOutlet.
* In Interface Builder: instantiate a Custom View, set it's class to Oscilloscope3, then connect it with the appropriae IBOutlet.

Options
-------
* 2 movement styles: all content moves to the left (like old EEG plotters) or an update event moves left to right along the traces
* choose trace and background colours
* choose separator lines between traces
* dashed zero line


Limitations
-----------
The present version only runs in 10.8(+) due to use of the new methode "CGColor"