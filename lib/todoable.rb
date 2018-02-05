require 'bundler/setup'
require "rest-client"
require "json"
require "todoable/version"
require_relative 'todoable/lists'
require_relative 'todoable/items'
require_relative 'todoable/error_parser'

module Todoable

  class NoCredentialsError < StandardError

    def initialize
      super
      "Incomplete credentials - send username + password OR token"
    end
  end
  class Client
    include Todoable::Client::Lists
    include Todoable::Client::Items

    BASE_URL = "http://todoable.teachable.tech/api"

    attr_reader :token, :expires_at, :base_url, :username, :password

    #Client can be instantiated with either username AND password or a token
    #If username, password, and token are all provided, token will be used
    #If token is provided, once token expires,or if token is invalid,  user will need to instantiate client with username and password or a valid token

    def initialize(username: nil , password: nil , token: nil)
      @base_url = BASE_URL
      @username = username
      @password = password
      @token = token

      raise Todoable::NoCredentialsError.new if incomplete_credentials?

      authenticate_client unless token
    end

    #Checks if there are enough credentials to start the client

    def incomplete_credentials?
      (username.nil? || password.nil?) && token.nil?
    end

    #Makes request to todoable server to get token and expires_at date/time

    def get_token
      return unless username && password
      begin
        response = RestClient::Request.execute(
        :method => :post,
        :url => url('authenticate'),
        :user => username,
        :password => password,
        :headers =>  {:content_type=>:json, :accept=>:json}
        )
        @token = JSON.parse(response.body)["token"]
        @expires_at = DateTime.parse(JSON.parse(response.body)["expires_at"])
      rescue RestClient::ExceptionWithResponse => err
        ErrorParser.parse_error(err.response)
      end
    end

    #Takes in http verb, path, and optional params to make request to todoable server

    def api_request(method:, path:, params: {})
      authenticate_client
      begin
        RestClient::Request.execute(
          method: method,
          url: url(path),
          payload: params.to_json,
          headers: headers
        )
      rescue RestClient::ExceptionWithResponse => err
        ErrorParser.parse_error(err.response)
      end
    end

    private

    #Allows for token expires_at date to be nil to accommodate Client instantiated with a token

    def valid_token?
       token && (expires_at.nil? || DateTime.now <= expires_at )
    end

    #
    def authenticate_client
      get_token unless valid_token?
    end

    def headers
      {
        :Authorization => "#{token}",
        :accept => :json,
        :content_type => :json
      }
    end

    def url(path)
      "#{base_url}/#{path}"
    end
  end
end
