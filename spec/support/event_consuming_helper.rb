# frozen_string_literal: true

require 'bunny'
require 'jwt-multisig'

module EventConsumingHelper
  class Consumer
    attr_reader :state, :response

    def initialize(exchange_name, routing_key)
      @exchange_name = exchange_name
      @routing_key = routing_key
      @state = :disabled
      @response = nil
      pp '----| Initialised consumer |----'
    end

    def call
      listen
    end

    private

    def listen
      @bunny_session = Bunny::Session.new(
        host: EVENT_API_RABBITMQ_HOST,
        port: EVENT_API_RABBITMQ_PORT,
        user: EVENT_API_RABBITMQ_USERNAME,
        password: EVENT_API_RABBITMQ_PASSWORD
      ).tap(&:start)
      @bunny_channel = @bunny_session.channel
      exchange = @bunny_channel.direct(@exchange_name)
      queue = @bunny_channel.queue('', auto_delete: true, durable: true)
                            .bind(exchange, routing_key: @routing_key)
      @state = :started
      pp '----| Subscribed for exchange |----'
      queue.subscribe(block: true, &method(:handle))
    end

    def handle(_delivery_info, _metadata, payload)
      @bunny_session.stop
      @response = verify_jwt(payload)
      @state = :finished
    end

    def verify_jwt(payload)
      application = @exchange_name.split('.').first
      JWT::Multisig.verify_jwt JSON.parse(payload),
                               application => jwt_public_key
    end

    def jwt_public_key
      pem = Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY'])
      OpenSSL::PKey.read(pem)
    end
  end
end
