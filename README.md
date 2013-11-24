# TheBigDB Javascript Wrapper

A simple javascript wrapper for making requests to the API of [TheBigDB.com](http://thebigdb.com). [Full API documentation](http://thebigdb.com/api).

## Install

Copy the file `lib/thebigjs.js`.  
Note that it is originally written in CoffeeScript, so you can also grab `src/thebigdb.coffee` if you wish.

## Usage

First, initialize the TheBigDB object:

    thebigdb = new TheBigDB;

Then make your requests, here is the structure:

    thebigdb.Statement(action, parameters, successCallback, errorCallback);


**[action]** => String of the action as described in the API (e.g. "search", "show", ...)  
**[parameters]** => Object. Request parameters as described in the API. Tip: Arrays like ["abc", "def"] will automatically be converted to {"0" => "abc", "1" => "def"}  
**[successCallback]** => (Optional) Function. Will be executed if the request is successful (with the json value status="success")
**[errorCallback]** => (Optional) Function. Will be executed if the request is not successful


Examples:

    thebigdb.Statement("search",
      {
        nodes: {property: "job", answer: "President of the United States"},
        period: {from: "2000-01-01 00:00:00", to: "2002-01-01 00:00:00"}
      }, function(data){
        console.log("Great Success!", JSON.stringify(data))
      }
    );

Will log something like:

    Great Success! {
      "status":"success",
      "statements": [
        {"nodes":{"subject":"Bill Clinton","property":"job","answer":"President of the United States"}, "id":"8e6aec89", "period":{"from":"1993-01-20 12:00:00","to":"2001-01-20 12:00:00"}},
        {"nodes":{"subject":"George W. Bush","property":"job","answer":"President of the United States"}, "id":"3f276738", "period":{"from":"2001-01-20 12:00:00","to":"2009-01-20 12:00:00"}}
      ],
      "total_results":2,
      "total_results_pages":1
    }

That's it!

## Other Features

You can access other parts of the API in the same way as statements:
    
    thebigdb.User(action, parameters, successCallback, errorCallback);

    // Examples
    thebigdb.User("show", {login: "christophe"}, function(data){ alert(data.user.karma) });

You can initialize the TheBigDB object with several configuration options, example:

    thebigdb = new TheBigDB({
      apiKey: null,                  // your private api key *
      useSSL: false,                 // use https instead of http when querying the API
      beforeRequestExecution: null,  // function that will be executed before all requests
      afterRequestExecution: null,   // function that will be executed after all requests
      ajaxSuccessCallback: null,     // will be executed after a successful request *
      ajaxErrorCallback: null        // will be executed after a failed request *
    })

    // Notes:
    // apiKey: Of course, since it's supposed to be private, you probably don't want to put it here for anyone else to see; You'll probably want to use a server-side wrapper instead.
    // ajaxSuccessCallback: Will be executed just before a "success" callback on request
    // ajaxErrorCallback: Will be executed just before a "error" callback on request


## Contributing

- Don't hesitate to send a pull request !
- CoffeeScript watcher: ```coffee --compile --watch --output lib/ src/```

## License

This software is distributed under the MIT License. Copyright (c) 2013, Christophe Maximin <christophe@thebigdb.com>
