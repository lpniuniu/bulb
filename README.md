System Maintaining ...

# Bulb

Richer, more powerful notification framework

## Features
- Signal objectification, self-test is repeated to create a signal
- Multi trigger signal combination
- Signal tracking
- Cancel signal
- Multi-state signal
- Weak data wrapper, so bulb will not strong references
- Signal Filter
- You can view the original value of the signal
- Has a signal state memory list, you decide whether to allow your signal at the time of fire, recover the data stored on the list
- Comprehensive Unit Test Coverage

## Requirements

- iOS 8.0 / watchOS 2.0 / Mac OS X 10.9

## Installation

#### CocoaPods
If you use CocoaPods to manage your dependencies, simply add
Bulb to your `Podfile`:

```ruby
pod 'Bulb', '~> 1.0.3'
```

## Quick start
create a new signal, each signal is BulbBoolSignal or BulbMutiStatusSignal's subclass object.

two step

- subclass 
- add a description

```objc
// BulbConnectToWifiSignal.h
#import "BulbBoolSignal.h"

@interface BulbConnectToWifiSignal : BulbBoolSignal

@end

// BulbConnectToWifiSignal.m
#import "BulbConnectToWifiSignal.h"

@implementation BulbConnectToWifiSignal

+ (NSString *)description
{
    return @"BulbConnectToWifiSignal will be fired when connect to wifi";
}

@end
```
register a signal, can be fired once

```objc
[[Bulb bulbGlobal] registerSignal:[BulbConnectToWifiSignal signal] block:^(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
	// do wifi work 
}];
```

fire a signal

```objc
[[Bulb bulbGlobal] fire:[BulbConnectToWifiSignal signal] data:@"firstData"];
```
register muti signals

```objc
[[Bulb bulbGlobal] registerSignals:@[[BulbConnectToWifiSignal signal], [BulbDataPrepareCompleteSignal signal]] block:^(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
	// wifi and data prepare compelete do something
}];
```

register forever signal, can be fired many times

```objc
[[Bulb bulbGlobal] registerSignal:[BulbConnectToWifiSignal signal] foreverblock:^BOOL(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
	// do wifi work
	return YES; // return yes if you want to continue
}];
```
### Advanced topics

####filter support
You can choose to filter the signal in some cases, the signal is equivalent to not happen

```objc
[[Bulb bulbGlobal] registerSignal:[BulbConnectToWifiSignal signal] block:^(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
      	// do wifi work
 } filterBlock:^BOOL(BulbSignal *signal) {
      if ([signal.data isEqualToString:@"data1"]) {
          return YES; // return yes if you want to filter
      }
      return NO;
}];
[[Bulb bulbGlobal] fire:[BulbConnectToWifiSignal signal] data:@"data1"]; // this signal is equivalent to not fire
[[Bulb bulbGlobal] fire:[BulbConnectToWifiSignal signal] data:@"data2"];
```
####origin status

You can view the signal to its original state to deal with some change logic

```objc
[[Bulb bulbGlobal] registerSignal:[BulbNetReachableSignal signalWithStatus:@"wifi"] foreverblock:^(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
   if ([[signalIdentifier2Signal objectForKey:[BulbNetReachableSignal identifier]].originStatus isEqualToString:@"wwlan"]) {
            // do work when wwlan -> wifi
   }
   return YES;
}];
 
// no work to do   
[[Bulb bulbGlobal] fire:[BulbNetReachableSignal signalWithStatus:@"no reachable"] data:nil];
[[Bulb bulbGlobal] fire:[BulbNetReachableSignal signalWithStatus:@"wifi"] data:nil];

// do work
[[Bulb bulbGlobal] fire:[BulbNetReachableSignal signalWithStatus:@"wwlan"] data:nil];
[[Bulb bulbGlobal] fire:[BulbNetReachableSignal signalWithStatus:@"wifi"] data:nil];
```

####signal tracking

The following will print all defined signals, as well as the history of signal registration and occurrence

```objc
NSString* allSignals = [[BulbRecorder sharedInstance] allSignals];
NSLog(@"%@", allSignals);
```
BULB_RECORDER need add to pre macro
## Communication

- If you **found a bug**, open an issue or submit a fix via a pull request.
- If you **have a feature request**, open an issue or submit a implementation via a pull request or hit me up on email <lpniuniu@gmail.com>
- If you **want to contribute**, submit a pull request onto the master branch.

## License

Bulb is released under an MIT license. See the LICENSE file for more information
