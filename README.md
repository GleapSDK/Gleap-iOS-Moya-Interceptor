# GleapMoyaPlugin

The Gleap Moya plugin intercepts all requests and forwards them to the Gleap SDK. You can use a plugin by simply declaring it during the initialization of the provider:

```
let provider = MoyaProvider<SampleType>(plugins: [GleapMoyaPlugin()])
```

Find more information on Gleap here:
[In-App Bug Reporting & Customer Feedback](https://www.gleap.io)
[Gleap Documentation](https://gleap.io/docs/ios/)
