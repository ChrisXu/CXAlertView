CXAlertView
===========

Custom alertView which allow you to add view as main content.

---
![ScreenShot 1](screenshot1.png) ![ScreenShot 2](screenshot2.png)

##Installation
---
* CocoaPods add `pod 'CXAlertView'`


##How to use
---

```Objective-C
// Create
- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView;
// Buttons
- (void)addButtonWithTitle:(NSString *)title type:(CXAlertViewButtonType)type handler:(CXAlertViewHandler)handler;
- (void)setDefaultButtonImage:(UIImage *)defaultButtonImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
// AlertView action
- (void)show;
- (void)dismiss;
// Operation
- (void)cleanAllPenddingAlert;
```


##Contact
---
#### Chris Xu

 * [@GitHub](https://github.com/ChrisXu1221)
 * [@Twitter](https://twitter.com/taterctl)
 * [@Mail](mailto:taterctl@gmail.com)

##License
---
Copyright (c) 2013 Chris Xu, Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.