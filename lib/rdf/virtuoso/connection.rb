require 'net/http/persistent'

module RDF::Virtuoso

  class Connection

    attr_reader :url
    attr_reader :options
    attr_reader :headers
    attr_reader :connected

    alias_method :connected?, :connected
    alias_method :open?, :connected

    def self.open(url, options={}, &block)
      self.new(url, options) do |conn|
        if conn.open(options) && block_given?
          case block.arity
          when 1 then block.call(conn)
          else conn.instance_eval(&block)
          end
        else
          conn
        end
      end
    end

    def initialize(url, options={}, &block)
      require 'addressable/uri' unless defined?(Addressable)
      @url = case url
             when Addressable::URI then url
             else Addressable::URI.parse(url)
             end
      @url = RDF::URI.new(to_hash)

      @headers   = options.delete(:headers) || {}
      @options   = options
      @connected = false
      @http = http_klass(@url.scheme)

      if block_given?
        case block.arity
        when 1 then block.call(self)
        else instance_eval(&block)
        end
      end
    end

    ##
    # Returns `true` unless this is an HTTPS connection.
    #
    # @return [Boolean]
    def insecure?
      !secure?
    end

    ##
    # Returns `true` if this is an HTTPS connection.
    #
    # @return [Boolean]
    def secure?
      scheme == :https
    end

    ##
    # Returns `:http` or `:https` to indicate whether this is an HTTP or
    # HTTPS connection, respectively.
    #
    # @return [Symbol]
    def scheme
      url.scheme.to_s.to_sym
    end

    ##
    # Returns `true` if there is user name and password information for this
    # connection.
    #
    # @return [Boolean]
    def userinfo?
      !url.userinfo.nil?
    end

    ##
    # Returns any user name and password information for this connection.
    #
    # @return [String] "username:password"
    def userinfo
      url.userinfo
    end

    ##
    # Returns `true` if there is user name information for this connection.
    #
    # @return [Boolean]
    def user?
      !url.user.nil?
    end

    ##
    # Returns any user name information for this connection.
    #
    # @return [String]
    def user
      url.user
    end

    ##
    # Returns `true` if there is password information for this connection.
    #
    # @return [Boolean]
    def password?
      !url.password.nil?
    end

    ##
    # Returns any password information for this connection.
    #
    # @return [String]
    def password
      url.password
    end

    ##
    # Returns the host name for this connection.
    #
    # @return [String]
    def host
      url.host.to_s
    end

    alias_method :hostname, :host

    ##
    # Returns `true` if the port number for this connection differs from the
    # standard HTTP or HTTPS port number (80 and 443, respectively).
    #
    # @return [Boolean]
    def port?
      !url.port.nil? && url.port != (insecure? ? 80 : 443)
    end

    ##
    # Returns the port number for this connection.
    #
    # @return [Integer]
    def port
      url.port
    end

    ##
    # Returns a `Hash` representation of this connection.
    #
    # @return [Hash{Symbol => Object}]
    def to_hash
      {
        :scheme   => url.scheme,
        :userinfo => url.userinfo,
        :host     => url.host,
        :port     => url.port,
        :path     => url.path
      }
    end

    ##
    # Returns the URI representation of this connection.
    #
    # @return [RDF::URI]
    def to_uri
      url
    end

    ##
    # Returns a string representation of this connection.
    #
    # @return [String]
    def to_s
      url.to_s
    end

    ##
    # Returns a developer-friendly representation of this connection.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, object_id, to_s)
    end

    ##
    # Establishes the connection to the Sesame server.
    #
    # @param  [Hash{Symbol => Object}] options
    # @yield  [connection]
    # @yieldparam [Connection] connection
    # @raise  [TimeoutError] if the connection could not be opened
    # @return [Connection]
    def open(options = {}, &block)
      unless connected?
        # TODO: support persistent connections
        @connected = true
      end

      if block_given?
        result = block.call(self)
        close
        result
      else
        self
      end
    end

    alias_method :open!, :open

    ##
    # Closes the connection to the Sesame server.
    #
    # You do not generally need to call {#close} explicitly.
    #
    # @return [void]
    def close
      if connected?
        # TODO: support persistent connections
        @connected = false
      end
    end

    alias_method :close!, :close

    ##
    # Returns an HTTP class or HTTP proxy class based on environment http_proxy & https_proxy settings
    # @return [Net::HTTP::Proxy]
    def http_klass(scheme)
      proxy_uri = nil
      case scheme
        when "http"
          proxy_uri = URI.parse(ENV['http_proxy']) unless ENV['http_proxy'].nil?
        when "https"
          proxy_uri = URI.parse(ENV['https_proxy']) unless ENV['https_proxy'].nil?
      end
      klass = Net::HTTP::Persistent.new(self.class.to_s, proxy_uri)
      klass.keep_alive = 120	# increase to 2 minutes
      klass
    end

    ##
    # Performs an HTTP GET request against the SPARQL endpoint.
    #
    # @param  [String, #to_s]          query
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def get(query, headers = {}, &block)
      url = self.url.dup
      url.query_values = {:query => query.to_s}

      request = Net::HTTP::Get.new(url.request_uri, @headers.merge(headers))
      request.basic_auth url.user, url.password if url.user && !url.user.empty?
      response = @http.request url, request
      if block_given?
        block.call(response)
      else
        response
      end
    end

    ##
    # Performs an HTTP POST request for the given Sesame `path`.
    #
    # @param  [String, #to_s]          path
    # @param  [String, #to_s]          data
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def post(query, headers = {}, &block)
      url = self.url.dup
      data = query.to_s

      request = Net::HTTP::Post.new(url.request_uri)
      request.set_form_data(query: data)
      request.basic_auth url.user, url.password if url.user && !url.user.empty?
      response = @http.request url, request

      if block_given?
        block.call(response)
      else
        response
      end

    end

  end
end
