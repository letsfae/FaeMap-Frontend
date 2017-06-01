# FaeMap-Frontend

* [Use of SwiftyJSON](#use-of-swiftyjson)
* [Use of GoogleMaps API](#use-of-googlemaps-and-googleplaces-sdk-for-ios)
* [Use of Delegate](#use-of-delegate-in-swift)
* [Parameter for Chat](#parameter-for-chat)
* [Code Style & Basic Rules (English)](#coding-style--basic-rules-english)
* [Code Style & Basic Rules (中文/Chinese)](#coding-style--basic-rules-中文chinese)

## Use of SwiftyJSON
[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) is a public framework, aims to deal with the JSON data from Backend. 

Because of the "Optional" and "Wrapping" features of Swift language, it becomes complex to get the real data and handle the error at the same time.

It is a must for Fae Frontend Developers to know how it works and how to use.

For Example,

The code would look like this:
```swift
if let statusesArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]],
    let user = statusesArray[0]["user"] as? [String: AnyObject],
    let username = user["name"] as? String {
    // Finally we got the username
}
```

It's not good. Even if we use optional chaining, it would be messy:
```swift
if let JSONObject = try JSONSerialization.jsonObject(with: data,, options: .allowFragments) as? [[String: AnyObject]],
    let username = (JSONObject[0]["user"] as? [String: AnyObject])?["name"] as? String {
        // There's our username
}
```

With SwiftyJSON all you have to do is:
```swift
import SwiftyJSON

let json = JSON(data: dataFromNetworking)
if let userName = json[0]["user"]["name"].string {
  //Now you got your value
}
```
For more details, please check [SwiftyJSON on Github](https://github.com/SwiftyJSON/SwiftyJSON)

## Use of GoogleMaps and GooglePlaces SDK for iOS
[GoogleMaps](https://developers.google.com/maps/documentation/ios-sdk/) Maps Documents

[GooglePlaces](https://developers.google.com/places/ios-api/) Places Document

Initial Two API in AppDelegate.swift file
```Swift
import GoogleMaps
import GooglePlaces

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ...
        GMSServices.provideAPIKey(GoogleMapKey)
        GMSPlacesClient.provideAPIKey(GoogleMapKey)
        ...
}
```

Note that GoogleMapKey is the same with two APIs, which can be generated through [Google Console](https://console.cloud.google.com)

## Use of Delegate in Swift
First, create a protocol and declare it in the class that will call delegate function.
```Swift
protocol FirstViewControllerDelegate: class {
    func someFunction(arg1: Int, arg2: String, arg3: Bool)
}
// We will use UIViewController as an example, 
// because we often pass data back from UIViewController class when finishing use of it.
// Typically, any class can be used here.
class YourFirstClass: UIViewController {
    // Declare your delegate to initialize protocol here
    weak var delegate: FirstViewControllerDelegate? // Use "?" to prevent bug occurring
}
```
Second, add protocol to the class that will execute the protocol function, "someFunction" for this example.
```Swift
class YourSecondClass: UIViewController, FirstViewControllerDelegate {
    // In this class, you must confirm the protocol "FirstViewControllerDelegate",
    // or error will occur.
    func someFunction(arg1: Int, arg2: String, arg3: Bool) {
        // Deal with your code here,
        // this function will call if YourFirstClass's delegate calls this function.
        print("arg1: \(arg1)")
        print("arg2: \(arg2)")
        print("arg3: \(arg3)")
    }
}
```

Last, call delegate function directly in YourFirstClass, and function details will be excuted in YourSecondClass
```Swift
class YourFirstClass: UIViewController {
    var delegate: FirstViewControllerDelegate?
    func viewDidLoad() {
        super.viewDidLoad()
        // In thie following way, someFunction will be called and arg1-3 will be passed to YourFirstClass
        self.delegate?.someFunction(arg1: 777, arg2: "777", arg3: true)
    }
}
```

P.S.

Adding "@objc" in front of protocol and adding "@objc optional" in front of protocol function name will make functions optional to use

Example:
```Swift
@objc protocol FirstViewControllerDelegate {
    @objc optional func someFunction(arg1: Int)
    @objc optional func anotherFunction(arg1: Int)
    func mustConfirmThisFunction(arg1: Int)
}
```
Then, in the class "YourSecondClass", the first two functions in the protocol are optional to use, but the third function must be implemented.

    
## Parameter for Chat
## 发送信息
`POST /xxx`

### auth
Yes

### parameters
| Name | Type | Description |
| --- | --- | --- |
| message | string() | 消息 |
| senderID | string() | ID |
| senderName | string() | 用户名|
| date | string() | 日期 |
| index | int() | 在聊天中的序号 |
| status | string() | 是否发送成功 |
| hasTimeStamp | boolean() | 是否显示时间戳 |
| data(optional) | string() | 只有text和location**不**需要 |
| snapImage(optional) | string() | 只有video和location需要 |
| longitude(optional) | string() | 只有location需要 |
| latitude(optional) | string() | 只有location需要 |
| videoDuration(optional) | int() | 只有video需要 |
| isHeartSticker(opt) | boolean() | 只有sticker需要 |

## Coding Style & Basic Rules (English)

### Name the Variables

**General Rules:**
* Name is customized name
* Name is capitalized    
```
	EX: boolIsFirstAppear
```
   
| Variable Type | Name Rule |
|---------------|:----------|
|UIButton|btnName|
|UICollectionView|cllcName|
|UILabel|lblName|
|UIImageView|imgName|
|UISearchBar|schbarName|
|UITableView|tblName|
|TableViewCell|cellName|
|UITextView|txtName|
|UITapGestureRecognizer|tapName|
|UIView|uiviewName|
|
|Array|arrName|
|Attribute for NSAttributedString|attrName|
|Boolean|boolName|
|CGPoint|pointName|
|CGFloat|floatName|
|Int|intName|
|Image|imgName|
|IndexPath|indexName|
|String|strName|
|SearchController|searchControllerName|
|ViewController|vcName|

### Conciseness
|Original|Concise|
|--------|------:|
|NSTextAlignment.center|.center|
|UIControlState.normal|.normal|
|UIControlState.touchUpInside|.touchUpInside|

### Other Rules
**Punctuation**
* Please have a space after punctuation
```
EX: UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
```
* But do not have a space after left parenthesis
* Not have space inside computation expression
```
EX: height: screenWidth-65
```
**If else statement**
* Not have parenthesis for condition
* Left bracket is in same line as “if”
* “Else” is in same line as right bracket for “if”
* Space between “else” and its following left bracket
```
EX:  if condition {
        } else {
        }
```
**Blank  lines**
* No more two blank lines in code

### Steps to pull and create new branch
* cd to project folder
* Close xcode (no need to fully quit)
* git branch
* git checkout master
* git pull
* Build xcode (Ctrl B)
* Create new branch in xcode
	* Source Control -> new branch -> name_DD/MM
	
    ```
    EX: sophie_0526
    ```
## Coding Style & Basic Rules (中文/Chinese)

### 组件名称缩写
   
| Variable Type | Name Rule |
|---------------|:----------|
|UIButton|btnName|
|UICollectionView|cllcName|
|UILabel|lblName|
|UIImageView|imgName|
|UISearchBar|schbarName|
|UITableView|tblName|
|TableViewCell|cellName|
|UITextView|txtName|
|UITapGestureRecognizer|tapName|
|UIView|uiviewName|
注意： 在缩写后要加上具体的用途名。btnSend

### 非组件名称缩写
| Variable Type | Name Rule |
|---------------|:----------|
|Array|arrName|
|Attribute for NSAttributedString|attrName|
|Boolean|boolName|
|CGPoint|pointName|
|CGFloat|floatName|
|Int|intName|
|Image|imgName|
|IndexPath|indexName|
|String|strName|
|SearchController|searchControllerName|
|ViewController|vcName|

### 代码规范
(1) 简写
|全称|简写|
|--------|------|
|NSTextAlignment.center|.center|
|UIControlState.normal|.normal|
|UIControlState.touchUpInside|.touchUpInside|
(2) 符号空格
* 符号后面留有一个空格
* 左括号右边不要有空格
* 复合表达式中不要有空格
```
 Ex: height: screenWidth-65
```
(3) if-else
* if 的条件不用小括号
* “{” 要与 if 在同一行
* else 要与 “}” 在同一行
* “{”、”}”与 else 之间的空格
```
EX:  if condition {
        } else {
        }
```
(4) 空行

任何地方不能超过两行的空行

### 资源命名缩写
* 前缀

前缀缩写 | 说明 
---- | --- 
Icon->ice | 用于图标
background->bg |  用于背景图
button->btn |  用于按钮图样
* 后缀

后缀缩写 | 说明 
---- | --- 
nor | 普通状态
hi |  高亮
press |  按下
select |  选中
unselect |  未选中
