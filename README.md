# GleapMoyaPlugin

The Gleap Moya plugin intercepts all requests and forwards them to the Gleap SDK.


## Installation

### Swift Package Manager

To get started, open your Xcode project and select *File* > *Add packages...*

Now you need to paste the following package URL to the search bar in the top right corner. Hit enter to confirm the search.

Package URL:
```https://github.com/GleapSDK/Gleap-iOS-Moya-Plugin```

Now select the Gleap package and hit *Add package* to add the Gleap SDK to your project.

### Manual installation

Simply copy the GleapMoyaPlugin.swift (Sources/GleapMoyaPlugin) from this repository into your project. In addition to that make sure to install Gleap & Moya.

## Using the plugin

After installing the plugin, you can use it by simply declaring it during the initialization of your Moya provider:

```
let provider = MoyaProvider<SampleType>(plugins: [GleapMoyaPlugin()])
```

Find more information on Gleap here:

[In-App Bug Reporting & Customer Feedback](https://www.gleap.io)

[Gleap Documentation](https://gleap.io/docs/ios/)
