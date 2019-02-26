module Toolbox
  module Helpers
    # TODO: Deal with config better.
    # @deprecated
    module Configuration
      def configure_root_url(root_url)
        raise ArgumentError, 'Peatio root URL must be provided.' if root_url.blank?
        @root_url = URI.parse(root_url).tap { |uri| uri.merge!('/api/v2/') if uri.path.empty? }
      end

      def configure_currencies(currencies)
        @currencies = currencies.to_s.split(',').map(&:squish).reject(&:blank?)
        raise ArgumentError, 'At least two fiat currencies must be provided.' if @currencies.count < 2
      end

      def configure_markets(markets)
        @markets = markets.to_s.split(',').map(&:squish).reject(&:blank?)
        raise ArgumentError, 'At least one market must be provided.' if @markets.count < 1
      end

      def configure_traders_number(n)
        raise ArgumentError, 'Number of traders must be greater than or equal to 2.' if n < 2
        @traders_number = n
      end

      def configure_orders(n)
        @orders = n
      end

      def configure_threads_number(n)
        raise ArgumentError, 'Number of threads must be at least 1' if n < 1
        @threads_number = n
      end

      def configure_volumes
        raise ArgumentError, 'The value of volume step must be greater than zero.' if @config.volume_step < 0.0
        raise ArgumentError, 'The value of minimum volume must be greater than zero.' if @config.min_volume < 0.0
        raise ArgumentError, 'The value of maximum volume must be greater than zero.' if @config.max_volume < 0.0
        raise ArgumentError, 'The value of minimum volume must be lower than the value of maximum volume.' if @config.min_volume > @config.max_volume
        @min_volume  = @config.min_volume
        @max_volume  = @config.max_volume
        @volume_step = @config.volume_step
      end

      def configure_prices
        raise ArgumentError, 'The value of price step must be greater than zero.' if @config.price_step < 0.0
        raise ArgumentError, 'The value of minimum price must be greater than zero.' if @config.min_price < 0.0
        raise ArgumentError, 'The value of maximum price must be greater than zero.' if @config.max_price < 0.0
        raise ArgumentError, 'The value of minimum price must be lower than the value of maximum price.' if @config.min_price > @config.max_price
        @min_price  = @config.min_price
        @max_price  = @config.max_price
        @price_step = @config.price_step
      end

      def configure_api_v2(jwt_key, jwt_algorithm)
        raise ArgumentError, 'API v2 private JWT key is missing.' if jwt_key.blank?
        raise ArgumentError, 'API v2 JWT algorithm is missing.' if jwt_algorithm.blank?
        @api_v2_jwt_key       = OpenSSL::PKey.read(Base64.urlsafe_decode64(jwt_key))
        @api_v2_jwt_algorithm = jwt_algorithm
      end

      def configure_management_api_v2(jwt_key, jwt_signer, jwt_algorithm)
        raise ArgumentError, 'Management API v2 private JWT key is missing.' if jwt_key.blank?
        raise ArgumentError, 'Management API v2 JWT signer is missing.' if jwt_signer.blank?
        raise ArgumentError, 'Management API v2 JWT algorithm is missing.' if jwt_algorithm.blank?
        @management_api_v2_jwt_key       = OpenSSL::PKey.read(Base64.urlsafe_decode64(jwt_key))
        @management_api_v2_jwt_signer    = jwt_signer
        @management_api_v2_jwt_algorithm = jwt_algorithm
      end
    end
  end
end
