describe "TheBigDB", ->

  describe "when initializing", ->
    it "returns a valid object", ->
      thebigdb = new TheBigDB
      expect(thebigdb.constructor).toEqual(TheBigDB)

    it "loads the default configuration", ->
      thebigdb = new TheBigDB
      expect(thebigdb.configuration.apiHost).toEqual("api.thebigdb.com")

    it "can override default configuration", ->
      thebigdb = new TheBigDB({apiHost: "test.host"})
      expect(thebigdb.configuration.apiHost).toEqual("test.host")

    describe "using SSL", ->
      beforeEach ->
        @thebigdb = new TheBigDB({useSSL: true})

      it "automatically updates the port to 443", ->
        expect(@thebigdb.configuration.apiPort).toEqual(443)


    describe "using SSL with a specified port", ->
      beforeEach ->
        @thebigdb = new TheBigDB({useSSL: true, apiPort: 1337})

      it "use the user set port", ->
        expect(@thebigdb.configuration.apiPort).toEqual(1337)
    
  # Since we can't mock AJAX requests, testing the request execution would be pointless

  describe "engine helper serializeQueryParams", ->
    it "works with simple a=b&c=d params", ->
      thebigdb = new TheBigDB
      expect(thebigdb.serializeQueryParams({a: "b", c: "d"})).toEqual("a=b&c=d")

    it "works with more complex imbricated params", ->
      thebigdb = new TheBigDB
      expect(thebigdb.serializeQueryParams({
        house: "bricks",
        animals: ["cat", "dog"],
        computers: {cool: true, drives: ["hard", "flash"]}
      })).toEqual("house=bricks&animals%5B0%5D=cat&animals%5B1%5D=dog&computers%5Bcool%5D=true&computers%5Bdrives%5D%5B0%5D=hard&computers%5Bdrives%5D%5B1%5D=flash")

  describe "engine helper mergeOptions", ->
    it "replaces the some default values while keeping the values non-overwritten", ->
      thebigdb = new TheBigDB
      foo = {a: "a", b: "b", c: "c"}
      bar = {d: "bar", b: "bar"}
      foo_plus_bar = {a: "a", b: "bar", c: "c", d: "bar"}
      expect(thebigdb.mergeOptions(foo, bar)).toEqual(foo_plus_bar)
