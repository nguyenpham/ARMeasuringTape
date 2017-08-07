# ARMeasuringTape

This code demonstrates how to use ARKit to measure lengths.
![ARMeasuringTape is measuring](https://github.com/nguyenpham/ARMeasuringTape/blob/master/measuringtape.gif)

## Suppose:
Measure will always drop at 20 cm from the central point of the device (you may change that distance)

## Some interesting techniques the code uses:
- Detect a point which is 20 cm from the center of the device
- Create and layout an object (a box in this case) between two points
- Create dynamically the image for the measure

## Discusion:
### Limits
1) The device's camera cannot touch to object since it needs a distance for focusing (focus length)

2) iOS has not exact distance between the camera and a given object (deeply it uses only one camera to work with ARKit, thus it has no information about depth)


3) The user looks into 3D world and drop the measure via his 2D screen. The app has no idea which object he actually want to measure and how far (from the device) it is

Because of all above issues, the measure may "float" between the device and the object of measuring.
![Measure floats between phone and object](https://github.com/nguyenpham/ARMeasuringTape/blob/master/measure0.jpg)

### Accuracy
Accuracy is depended much on how parallell between measure and object, the angle of the phone and object to align two ends of the measure with the object (usually it is bad):
![Accuracy problem](https://github.com/nguyenpham/ARMeasuringTape/blob/master/measure1.jpg)

### Not good for measuring
1) short lengths / distances
2) far objects more than 20 cm from user's phone (we can increase that distance but it may reduce accuracy)
3) when ARKit tracking does not work well, say, in dark light, or the surface has not enough texture

### Good for measuring
1) when you don't have any physical measure ;)
2) to get quick estimate
3) not too short length objects

## Known problems
The measure uses an image to display marks and numbers. The size of that image is limited about 16384 pixels. Thus we limit the max length of the measure about 1.5m.
There are some solutions for measuring over that limit length.
1) Don't use image. We may use a colour or simple texture (has no mark / number) for the measure. It will be shown it as a tube / line. The number of length may be shown somewhere
2) Use multi measures, one after one

## Requirements

### Build

Xcode 9.0, iOS 11.0 SDK

### Runtime

iOS 11.0 + A9 processors (from iPhone 6s or iPad 2017)

Copyright (C) 2017 Softgaroo / Nguyen Hong Pham. All rights reserved.
