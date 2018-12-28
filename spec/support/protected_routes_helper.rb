# frozen_string_literal: true

require 'faraday-cookie_jar'

module ProtectedRoutesHelper
  class Connection
    def initialize(email, password)
      @connection = Faraday.new(url: TOOLBOX_HOST) do |faraday|
        faraday.use :cookie_jar
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end

      start_session email, password
    end

    def start_session(email, password)
      @connection.post do |req|
        req.url 'api/v2/barong/identity/sessions'
        req.headers['Content-Type'] = 'application/json'
        req.body = { email: email, password: password }.to_json
      end
    end

    def get(path, params = nil)
      @connection.get do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.body = params.to_json
      end
    end

    def post(path, params = nil)
      @connection.post do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.body = params.to_json
      end
    end
  end
end
