require 'api_smith'
require 'rdf'
require 'uri'

module RDF
  module Virtuoso
    class Repository
      include APISmith::Client

      RESULT_JSON = 'application/sparql-results+json'.freeze
      RESULT_XML  = 'application/sparql-results+xml'.freeze

      class Parser::SparqlJson < HTTParty::Parser
        SupportedFormats.merge!({ RESULT_JSON => :json })
      end

      class ClientError < StandardError; end
      class MalformedQuery < ClientError; end
      class NotAuthorized < ClientError; end
      class ServerError < StandardError; end

      # TODO: Look at issues with HTTParty Connection reset
      #persistent
      maintain_method_across_redirects true

      attr_reader :uri, :update_uri, :username, :password, :auth_method

      def initialize(uri, opts={})
        @uri             = URI.parse(uri)
        @update_uri      = URI.parse(opts[:update_uri]) if opts[:update_uri]
        @base_uri        = "#{@uri.scheme}://#{@uri.host}"
        @base_uri       += ":" + @uri.port.to_s if @uri.port
        @username        = opts[:username]    || nil 
        @password        = opts[:password]    || nil
        @auth_method     = opts[:auth_method] || 'digest'

        @sparql_endpoint = @uri.request_uri
        @sparul_endpoint = @update_uri.nil? ? @sparql_endpoint : @update_uri.request_uri
        self.class.base_uri @base_uri
      end

      READ_METHODS  = %w(select ask construct describe)
      WRITE_METHODS = %w(insert insert_data update delete delete_data create drop clear)

      READ_METHODS.each do |m|
        define_method m do |*args|
          response = api_get *args
        end
      end

      WRITE_METHODS.each do |m|
        define_method m do |*args|
          response = api_post *args
        end
      end


      def query(pattern, &block)
        case pattern
          when RDF::Statement
            query(pattern.to_hash)
          when Array
            query(RDF::Statement.new(*pattern))
          when Hash
            statements = []
            results = query_attributes(pattern)
            results.each do |r|
              statements << RDF::Statement.new(
                  :subject   => pattern[:subject],
                  :predicate => r[:predicate],
                  :object    => r[:object],
                  :context   => nil
              )
            end

            case block_given?
              when true
                  statements.each(&block)
              else
                  statements.extend(RDF::Enumerable, RDF::Queryable)
            end
          else
              super(pattern)
        end
      end

      def query_attributes(hash)
        conditions = []
        [:subject, :predicate, :object].each do |resource|
          if hash[resource].nil?
            conditions << resource
          else
            conditions << hash[resource]
          end
        end
        query  = RDF::Virtuoso::Query.select.where(conditions)
        api_get query
      end

      private

      def check_response_errors(response)
        case response.code
        when 401
          raise NotAuthorized.new
        when 400
          raise MalformedQuery.new(response.parsed_response)
        when 500..599
          raise ServerError.new(response.body)
        end
      end

      def headers
        { 'Accept' => [RESULT_JSON, RESULT_XML].join(', ') }
      end

      def base_query_options
        { :format => RESULT_JSON }
      end

      def base_request_options
        { :headers => headers }
      end

      def extra_request_options
        case @auth_method
        when 'basic'
          { :basic_auth => auth }
        when 'digest'
          { :digest_auth => auth }
        end
      end
      
      def auth
        { :username => @username, :password => @password }
      end
      
      def api_get(query, options = {})
        # prefer sparul endpoint with auth if present to allow SELECT/CONSTRUCT access to protected graphs
        if @sparul_endpoint
          # self.class.endpoint @sparul_endpoint
          self.class.endpoint ""
          get '/sparql', :extra_query => { :query => query }.merge(options),
                   :extra_request => extra_request_options,
                   :transform => RDF::Virtuoso::Parser::JSON
        else
          # self.class.endpoint @sparql_endpoint
          self.class.endpoint ""
          get '/sparql', :extra_query => { :query => query }.merge(options),
                   :transform => RDF::Virtuoso::Parser::JSON
        end
      end

      def api_post(query, options = {})
        # self.class.endpoint @sparul_endpoint
        self.class.endpoint ""
        post '/sparql', :extra_body => { :query => query }.merge(options),
                  :extra_request => extra_request_options,
                  :response_container => [
                    "results", "bindings", 0, "callret-0", "value"]
      end

    end
  end
end
