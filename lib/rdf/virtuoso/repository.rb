require 'api_smith'
require 'rdf'

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

      attr_reader :username, :password, :uri, :auth_method

      def initialize(uri, opts={})
        self.class.base_uri uri
        @uri = uri
        @username        = opts[:username]    ||= nil 
        @password        = opts[:password]    ||= nil
        @auth_method     = opts[:auth_method] ||= 'digest'
      end

      READ_METHODS  = %w(select ask construct describe)
      WRITE_METHODS = %w(query insert insert_data update delete delete_data create drop clear)

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
        { :format => 'json' }
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
        self.class.endpoint 'sparql'
        get '/', :extra_query => { :query => query }.merge(options), 
                 :transform => RDF::Virtuoso::Parser::JSON
      end

      def api_post(query, options = {})
        self.class.endpoint 'sparql-auth'
        post '/', :extra_body => { :query => query }.merge(options), 
                  :extra_request => extra_request_options,
                  :response_container => [
                    "results", "bindings", 0, "callret-0", "value"]
      end

    end
  end
end
