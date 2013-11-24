class @TheBigDB
  constructor: (options = {}) ->
    version = "1.1.0"

    defaultConfiguration =
      apiKey: null
      useSSL: false
      verifySSLCertificates: false # Not yet implemented
      beforeRequestExecution: null
      afterRequestExecution: null
      ajaxSuccessCallback: null
      ajaxErrorCallback: null
      apiHost: "api.thebigdb.com"
      apiPort: 80
      apiVersion: "1"

    @configuration = @mergeOptions(defaultConfiguration, options)

    # automatically assigns 443 port if using SSL,
    # unless the user specifically wants another one
    @configuration.apiPort = 443 if @configuration.useSSL and !options.apiPort
    @clientUserAgent = {publisher: "thebigdb", version: version, language: "javascript"}


  ##############
  ## Resources
  ##############

  Statement: (action, params, successCallback, errorCallback) ->
    # shortcuts for params:
    # with this, you can pass directly ["iPhone", "weight"]
    params = {nodes: params} if params.constructor == Array
    # this way, you can pass directly "8ba34c..."
    params = {id: params} if params.constructor == String

    method = if action in ["get", "show", "search"] then "GET" else "POST"
    path = "/statements/#{action}"
    @executeRequest(method, path, params, successCallback, errorCallback)

  User: (action, params, successCallback, errorCallback) ->
    method = "GET"
    path = "/users/#{action}"
    @executeRequest(method, path, params, successCallback, errorCallback)


  ##############
  ## Engine
  ##############

  executeRequest: (method, path, params, successCallback, errorCallback) ->
    params.api_key = @configuration.apiKey
    # preparing the destination URL
    scheme = if @configuration.useSSL then "https" else "http"
    url = "#{scheme}://#{@configuration.apiHost}:#{@configuration.apiPort}/v#{@configuration.apiVersion}#{path}"
    url += "?"+@serializeQueryParams(params) if method == "GET"

    # preparing and sending the XHR request
    xhr = if window.ActiveXObject
        new window.ActiveXObject("Microsoft.XMLHTTP")
      else
        new XMLHttpRequest()

    @configuration.beforeRequestExecution?()

    xhr.open(method, url, true)
    xhr.setRequestHeader("X-TheBigDB-Client-User-Agent", JSON.stringify(@clientUserAgent))
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded") if method == "POST"

    xhr.onreadystatechange = =>
      if xhr.readyState is 4
        @configuration.afterRequestExecution?()

        response = try
            JSON.parse(xhr.responseText);
          catch e
            {status: "error", error: {code: "0000", description: "The server gave an invalid JSON text: #{xhr.responseText}"}}
          
        if response.status == "success"
          @configuration.ajaxSuccessCallback?(response)
          successCallback?(response)
        else
          @configuration.ajaxErrorCallback?(response)
          errorCallback?(response)

        @last_response = response

    if method == "GET"
      xhr.send(null)
    else
      xhr.send(@serializeQueryParams(params))

  ##############
  ## Engine Helpers
  ##############
  
  # serializeQueryParams({house: "bricks", animals: ["cat", "dog"], computers: {cool: true, drives: ["hard", "flash"]}})
  # => house=bricks&animals%5B%5D=cat&animals%5B%5D=dog&computers%5Bcool%5D=true&computers%5Bdrives%5D%5B%5D=hard&computers%5Bdrives%5D%5B%5D=flash
  # which will be read by the server as:
  # => house=bricks&animals[]=cat&animals[]=dog&computers[cool]=true&computers[drives][]=hard&computers[drives][]=flash
  serializeQueryParams: (obj, prefix) ->
    str = for key, value of obj
      param_key = if prefix then "#{prefix}[#{key}]" else key

      if typeof(value) == "object"
        @serializeQueryParams(value, param_key)
      else
        encodeURIComponent(param_key) + "=" + encodeURIComponent(value)

    str.join("&")


  mergeOptions: (obj1, obj2) ->
    ret = obj1
    for key, value of obj2
      ret[key] = value
    ret