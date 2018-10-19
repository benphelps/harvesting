# frozen_string_literal: true

require "http"
require "json"

module Harvesting
  class Client
    DEFAULT_HOST = "https://api.harvestapp.com/v2"

    attr_accessor :access_token, :account_id

    #
    # @param opts
    #
    def initialize(access_token: ENV['HARVEST_ACCESS_TOKEN'], account_id: ENV['HARVEST_ACCOUNT_ID'])
      @access_token = access_token.to_s
      @account_id = account_id.to_s

      if @account_id.length == 0 || @access_token.length == 0
        raise ArgumentError.new("Access token and account id are required. Access token: '#{@access_token}'. Account ID: '#{@account_id}'.")
      end
    end

    def me
      Harvesting::Models::User.new(get("users/me"), client: self)
    end

    def clients
      get("clients")["clients"].map do |result|
        Harvesting::Models::Client.new(result, client: self)
      end
    end

    def contacts
      get("contacts")["contacts"].map do |result|
        Harvesting::Models::Contact.new(result, client: self)
      end
    end

    def time_entries(opts = {})
      Harvesting::Models::TimeEntries.new(get("time_entries", opts), client: self)
    end

    def projects(opts = {})
      Harvesting::Models::Projects.new(get("projects", opts), client: self)
    end

    def tasks(opts = {})
      Harvesting::Models::Tasks.new(get("tasks", opts), client: self)
    end

    def users(opts = {})
      Harvesting::Models::Users.new(get("users", opts), client: self)
    end

    def create(entity)
      url = "#{DEFAULT_HOST}/#{entity.path}"
      uri = URI(url)
      response = http_response(:post, uri, body: entity.to_hash)
      entity.attributes = JSON.parse(response.body)
      entity
    end

    def update(entity)
      url = "#{DEFAULT_HOST}/#{entity.path}"
      uri = URI(url)
      response = http_response(:patch, uri, body: entity.to_hash)
      entity.attributes = JSON.parse(response.body)
      entity
    end

    private

    def get(path, opts = {})
      url = "#{DEFAULT_HOST}/#{path}"
      url += "?#{opts.map {|k, v| "#{k}=#{v}"}.join("&")}" if opts.any?
      uri = URI(url)
      response = http_response(:get, uri)
      JSON.parse(response.body)
    end

    def http_response(method, uri, opts = {})
      response = nil

      http = HTTP["User-Agent" => "Ruby Harvest API Sample",
                  "Authorization" => "Bearer #{@access_token}",
                  "Harvest-Account-ID" => @account_id]
      params = {}
      if opts[:body]
        params[:json] = opts[:body]
      end
      response = http.send(method, uri, params)

      raise Harvesting::AuthenticationError.new(response.to_s) if auth_error?(response)
      raise Harvesting::UnprocessableRequest.new(response.to_s) if response.code.to_i == 422

      response
    end

    def auth_error?(response)
      response.code.to_i == 403 || response.code.to_i == 401
    end
  end
end
