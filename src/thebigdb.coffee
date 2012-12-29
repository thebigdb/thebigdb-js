class @TheBigDB
  constructor: (options = {}) ->
    version = "0.1.0"

    defaultConfiguration =
      apiKey: ""
      useSsl: false
      verifySslCertificates: false # Not yet implemented
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
    @configuration.apiPort = 443 if @configuration.useSsl and !options.apiPort
    @clientUserAgent = {publisher: "thebigdb", version: version, language: "javascript"}


  ##############
  ## Resources
  ##############

  Sentence: (action, params, successCallback, errorCallback) ->
    # shortcuts for params:
    # with this, you can pass directly ["iPhone", "weight"]
    params = {nodes: params} if params.constructor == Array
    # this way, you can pass directly "8ba34c..."
    params = {id: params} if params.constructor == String

    if action in ["get_next_node", "get_next_nodes"]
      method = "GET"
      path = "/sentences/search"
      params["nodes_count_exactly"] = params.nodes.length + 1

      # a little suitcase of variables
      [@_action, @_successCallback] = [action, successCallback]

      customSuccessCallback = (response) =>
        # we make an array of the last nodes for each sentences
        nodes = sentence.nodes[-1..] for sentence in response.sentences
        # and if we just want the top one, return a string
        result = if @_action == "get_next_node" then nodes[0] else nodes
        @_successCallback?(result)

      @executeRequest(method, path, params, customSuccessCallback, errorCallback)
    else
      method = if action in ["get", "show", "search"] then "GET" else "POST"
      path = "/sentences/#{action}"
      @executeRequest(method, path, params, successCallback, errorCallback)


  Toolbox: ->
    Units: (action, params, successCallback, errorCallback) =>
      method = "GET"
      path = "/toolbox/units/#{action}"
      @executeRequest(method, path, params, successCallback, errorCallback)



  ##############
  ## Engine
  ##############

  executeRequest: (method, path, params, successCallback, errorCallback) ->
    # preparing the destination URL
    scheme = if @configuration.useSsl then "https" else "http"
    url = "#{scheme}://#{@configuration.apiHost}:#{@configuration.apiPort}/api/v#{@configuration.apiVersion}#{path}"
    url += "?"+@serializeQueryParams(params) if method == "GET"

    # preparing and sending the XHR request
    xhr = if window.ActiveXObject
        new window.ActiveXObject("Microsoft.XMLHTTP")
      else
        new XMLHttpRequest()

    @configuration.beforeRequestExecution?()

    xhr.open(method, url, true)
    xhr.setRequestHeader("X-TheBigDB-Client-User-Agent", JSON.stringify(@clientUserAgent))

    xhr.onreadystatechange = =>
      if xhr.readyState is 4
        @configuration.afterRequestExecution?()

        response = try
            JSON.parse(xhr.responseText);
          catch e
            {status: "error", error: {code: 0, message: "The server gave an invalid JSON text: #{xhr.responseText}"}}
          
        if response.status == "success"
          @configuration.ajaxSuccessCallback?(response)
          successCallback?(response)
        else
          @configuration.ajaxErrorCallback?(response)
          errorCallback?(response)

        @last_response = response

    xhr.send @serializeQueryParams(params)

  ##############
  ## Engine Helpers
  ##############
  
  # serializeQueryParams({{house: "bricks", animals: ["cat", "dog"], computers: {cool: true, drives: ["hard", "flash"]}})
  # => house=bricks&animals%5B%5D=cat&animals%5B%5D=dog&computers%5Bcool%5D=true&computers%5Bdrives%5D%5B%5D=hard&computers%5Bdrives%5D%5B%5D=flash
  # which will be read by the server as:
  # => house=bricks&animals[]=cat&animals[]=dog&computers[cool]=true&computers[drives][]=hard&computers[drives][]=flash
  serializeQueryParams: (obj, prefix) ->
    str = for key, value of obj
      param_key = if obj.constructor == Array
          if prefix then "#{prefix}[]" else key
        else
          if prefix then "#{prefix}[#{key}]" else key

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