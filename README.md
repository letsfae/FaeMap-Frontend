# FaeMap-Frontend

## Use of SwiftyJSON
[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) is a public framework, aims to deal with the JSON data from Backend. 

Because of the "Optianal" and "Wrapping" features of Swift language, it becomes complex to get the real data and handle the error as the same time.

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
let json = JSON(data: dataFromNetworking)
if let userName = json[0]["user"]["name"].string {
  //Now you got your value
}
```
For more details, please check [SwiftyJSON on Github](https://github.com/SwiftyJSON/SwiftyJSON)



## License
2016 Faevorite Inc.
    
