TheBigDB = function(options){

  var version = "0.1.0";

  var default_configuration = {
    api_key: "",
    use_ssl: false,
    verify_ssl_certificates: false, // Not yet implemented
    before_request_execution: null, // Not yet implemented
    after_request_execution: null, // Not yet implemented
    api_host: "api.thebigdb.com",
    api_port: 80,
    api_version: "1"
  };

  var configuration = {};
  var client_user_agent = {};
  var user_agent = null;
  var response = null;

  var merge_options = function(obj1, obj2){
    var obj3 = {};
    for(var attrname in obj1){
      obj3[attrname] = obj1[attrname];
    }
    for(var attrname in obj2){
      obj3[attrname] = obj2[attrname];
    }
    return obj3;
  };


  function initialize(options){
    if(typeof(options) == "undefined") options={};
    // Set basic configuration
    configuration = merge_options(default_configuration, options);

    configuration.api_port = (configuration.use_ssl == true) ? 443 : 80;

    if(typeof(options.api_port) != "undefined"){
      configuration.api_port = options.api_port;
    }

    // Prepare standard requests headers
    user_agent = "TheBigDB JavascriptWrapper/"+version;

    client_user_agent = {
      publisher: "thebigdb",
      version: version,
      language: "javascript"
    };

  };

  initialize(options);


  // AJAX stuff
  // Imported from http://stackoverflow.com/questions/2557247/easiest-way-to-retrieve-cross-browser-xmlhttprequest
  var XMLHttpFactories = [
    function () {return new XMLHttpRequest()},
    function () {return new ActiveXObject("Msxml2.XMLHTTP")},
    function () {return new ActiveXObject("Msxml3.XMLHTTP")},
    function () {return new ActiveXObject("Microsoft.XMLHTTP")}
  ];

  function createXMLHTTPObject(){
    var xmlhttp = false;
    for(var i=0;i<XMLHttpFactories.length;i++){
      try {
        xmlhttp = XMLHttpFactories[i]();
      }
      catch(e){
        continue;
      }
      break;
    }
    return xmlhttp;
  };

  // Inspired by http://stackoverflow.com/questions/1714786/querystring-encoding-of-a-javascript-object
  function serializeQueryParams(obj, prefix){
    var str = [];
    for(var p in obj) {
      if(obj.constructor == Array){
        var k = prefix ? prefix + "[]" : p;
      } else {
        var k = prefix ? prefix + "[" + p + "]" : p;
      }
      
      var v = obj[p];

      str.push(typeof v == "object" ? serializeQueryParams(v, k) : encodeURIComponent(k) + "=" + encodeURIComponent(v));
    }
    return str.join("&");
  };




  this.execute_request = function(method, path, params, callback){
    method = method.toUpperCase();

    if(configuration.use_ssl == true){
      var scheme = "https";
    } else {
      var scheme = "http";
    }

    var url = scheme+"://"+configuration.api_host+":"+configuration.api_port;
    url = url+"/v"+api_version;

    if(path[0] != "/"){
      path = "/"+path;
    }

    url = url+path;

    if(method == "GET"){
      url = url+"?"+serializeParams(params);
    }

    var req = createXMLHTTPObject();
    if (!req) return;

    req.open(method, url, true);

    req.setRequestHeader("User-Agent", user_agent);
    req.setRequestHeader("X-TheBigDB-Client-User-Agent", JSON.stringify(client_user_agent));
    if(method == "POST"){
      req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    }

    req.onreadystatechange = function(){
      if (req.readyState != 4) return;
      if (req.status != 200 && req.status != 304) {
        // alert('HTTP error ' + req.status);
        return;
      }
      
      var parsed_answer = JSON.parse(req.responseText);
      callback(parsed_answer);
    }
    if (req.readyState == 4) return;
    req.send(serializeQueryParams(params));

  };

  // Resources
  this.Sentence = function(action, params, callback){
    if(action == "get" || action == "show"){
      execute_request("GET", params, callback);
    } else if(action == "auto_complete" || action == "autocomplete"){
      // TODO
    } else if(action == "search"){
      // TODO
    } else if(action == "create"){
      // TODO
    } else if(action == "upvote"){
      // TODO
    } else if(action == "downvote"){
      // TODO
    } else if(action == "report"){
      // TODO
    } else if(action == "destroy"){
      // TODO
    } 
    return this;
  };


};