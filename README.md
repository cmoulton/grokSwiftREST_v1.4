# From JSON API to Swift App

You need to build an iOS app around your team's API or integrate a third party API. You need a quick, clear guide to demystify Xcode and Swift. No esoteric details about Core Anything or mathematical analysis of `flatMap`. Only the nitty gritty that you need to get real work done now: pulling data from your web services into an iOS app, without tossing your MacBook or Mac Mini through a window.

You just need the bare facts on how to get CRUD done on iOS. That's what this book will do for you.

## What Will You Be Able to Do?

After reading this book you'll be able to:

- Analyze a JSON response from a web service call and write Swift code to parse it into model objects either manually or using `Codable`
- Display those model objects in a table view so that when the user launches the app they have a nice list to scroll through
- Add authentication to use web service calls that require OAuth 2.0, a username/password, or a token
- Transition from the main table view to a detail view for each object, possibly making another web service call to get more info about the object
- Let users add, modify and delete objects (as long as your web service supports it)
- Hook into more web service calls to extend your app, like adding user profiles or letting users submit comments or attach photos to objects

To achieve those goals we'll build out an app based on the GitHub API, focusing on gists. If you're not familiar with gists, they're basically just text snippets, often code written by a GitHub user, here are mine: [cmoulton gists](https://gist.github.com/cmoulton/). Your model objects might be bus routes, customers, chat messages, or whatever kind of object is core to your app. We'll start by figuring out how to make API calls in Swift then we'll start building out our app one feature at a time to make it more and more useful to users:

- Show a list of all public gists in a table view
- Load more results when the user scrolls down
- Let them pull to refresh to get the latest public gists
- Load images from URLs into table view cells
- Use OAuth 2.0 for authentication to get lists of private and starred gists
- Have a detail view for each gist showing the text
- Allow users to add new gists, star and unstar gists, and delete gists
- Handle not having an internet connection with warnings to the user and saving the gists on the device

## Who Is This Book For?

- Software developers getting started with iOS but experienced in other languages
- Front-end devs looking to implement native UIs for iOS apps
- Back-end devs tasked with getting the data into the user's hands on iOS
- Android, Windows Phone, Blackberry, Tizen, Symbian & Palm OS devs looking to expand their web service backed apps to iOS
- Anyone whose boss is standing over their shoulder asking why the API data isn't showing up in the table view yet

## Who Is This Book Not For?

- Complete newcomers to programming. You should have a decent grasp of at least one object-oriented programming language or have completed several introduction to iOS tutorials in Swift
- Designers, managers, UX pros, etc. It's a programming book. All the monospace font inserts will probably drive you crazy
- Cross-platform developers committed to their tools (like React Native & Xamarin). This book is all Swift & native UI, all the time
- Programmers building apps that have little or no web service interaction
- Game devs, unless you're tying in a REST-like API

## Using This Book

This book is mostly written as a tutorial in implementing the gists demo app. Depending on how you learn best and how urgently you need to implement your own app, there are two different approaches you might take:

1. Work through the tutorials as written, creating an app for GitHub Gists. You'll understand how that app works and later be able to apply it to your own apps.
2. Read through the tutorials but implement them for your own app and API. Throughout the text I'll point out where you'll need to analyze your own requirements and API to help you figure out how to modify the example code to work with your API. Those tips will look like this:

X> List the tasks or user stories for your app. Compare them to the list for the gists app, focusing on the number of different objects (like stars, users, and gists) and the types of action taken (like viewing a list, viewing an object's details, adding, deleting, etc.).

We'll start with that task in the next chapter. We'll analyze our requirements and figure out just what we're going to build. Then we'll start building the gists app, right after an introduction to making network calls and parsing JSON in Swift.

## What We Mean By Web Services / APIs / REST / CRUD

Like anything in tech there are plenty of buzzwords around web services. For a while it was really trendy to say your web services were RESTful. If you want to read the theory behind it, head over to [Wikipedia](https://en.wikipedia.org/wiki/Representational_state_transfer). For our purposes in this book, all I mean by "REST web service" or even when I say "web service" or "API" is that we can send an HTTP request and we get back some data in a format that's easy to use in our app. Usually that format will be [JSON](http://www.json.org/).

Web services are wonderful since they let you use existing web-based systems in your own apps. There's always a bit of a learning curve when you're using any with any web service for the first time. Every one has its own quirks but most of the integration is similar enough that we can generalize how to integrate them into our iOS apps.

If you want an argument about whether or not a web service is really RESTful you're not going to find it here. We've got work that just needs to *get done*.

## What about GraphQL?

[GraphQL](http://graphql.org) is an alternative to REST for APIs. Instead of predetermined resources, GraphQL lets you query your API to just get the data that you currently need. Most of the code in this book will work just as well with a GraphQL API. You'll have to do a little more work to figure out what queries you need to make instead of choosing from a list of REST endpoints.

GraphQL is still fairly new so this book will continue to use the v3 GitHub REST API. 

## JSON

In this book we're going to deal with web services that return [JSON](http://www.json.org/). JSON is hugely common these days so it's probably what you'll be dealing with. Of course, there are other return types out there, like XML. This book won't cover responses in anything but JSON but it will encapsulate the JSON parsing so that you can replace it with whatever you need to without having to touch a ton of code. If you are dealing with XML response you should look at [NSXMLParser](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSXMLParser_Class/).

## Versions

This is version 1.4 of this book. It uses Swift 4, iOS 11 (with support back to iOS 10), and Xcode 9. When we use libraries we'll explicitly list the versions used. The most commonly used one is Alamofire 4.7.

If you need or want an older version of this book for Swift 3, Swift 2.2 or Swift 2.0, [email me at christina@teakmobile.com](mailto:christina@teakmobile.com).

## Source Code

All sample code is available [on GitHub](https://github.com/cmoulton/grokSwiftREST_v1.4/) under the [MIT license](https://opensource.org/licenses/MIT). Links are provided throughout the text. Each chapter has a tag allowing you to check out the code in progress up to the end of that chapter.

Individuals are welcome to use the code for commercial and open-source projects. As a courtesy, please provide attribution to "Teak Mobile Inc." or "Christina Moulton". For more information, review the [complete license agreement in the GitHub repo](https://github.com/cmoulton/grokSwiftREST_v1.4/blob/master/LICENSE.txt).

<a href="https://leanpub.com/iosappswithrest/">Buy now for $29</a>
<p>or <a href="https://leanpub.com/iosappswithrest/">read the free sample chapters</a></p>

## Quick Start

- Go to [https://github.com/settings/developers](https://github.com/settings/developers)
- Register a new GitHub app. Use the callback URL `grokgithuboauth://`
- Get the client ID & secret
- Copy those values into the top of GitHubAPIManager:

<pre><code>let clientID: String = "1234567890"
let clientSecret: String = "abcdefghijkl"
</code></pre>

- Enjoy!
