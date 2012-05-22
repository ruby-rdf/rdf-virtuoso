require 'api_smith'

module RDF
  module Virtuoso
    class Client
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

      attr_reader :username, :password, :uri

      def initialize(uri, username = nil, password = nil)
        self.class.base_uri uri
        @uri = uri
        @username = username
        @password = password
      end

      READ_METHODS  = %w(select ask construct describe)
      WRITE_METHODS = %w(insert update delete create drop clear)

      READ_METHODS.each do |m|
        define_method m do |*args|
          api_get *args
        end
      end

      WRITE_METHODS.each do |m|
        define_method m do |*args|
          api_post *args
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
        { format: 'json' }
      end

      def base_request_options
        { headers: headers }
      end

      def basic_auth
        { username: @username, password: @password }
      end

      def api_get(query, options = {})
        self.class.endpoint 'sparql'
        get '/', extra_query: { query: query }.merge(options), 
          transform: RDF::Virtuoso::Parser::JSON
      end

      def api_post(query, options = {})
        self.class.endpoint 'sparql-auth'
        post '/', extra_query: { query: query }.merge(options), 
                  extra_request: { basic_auth: basic_auth },
                  response_container: [
                    "results", "bindings", 0, "callret-0", "value"]
      end

    end
  end
end
