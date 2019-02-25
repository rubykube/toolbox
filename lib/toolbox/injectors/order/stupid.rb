require_relative "base"

module Toolbox::Injectors
  module Order
    class Stupid < Base
      def prepare!
        @generated_orders = 0
        init_volumes
        init_prices
        # Do nothing because we will generate orders on fly here.
      end

      # TODO: Validate options before moving.
      def init_volumes
        @volumes = []
        volume  = @options.min_volume
        loop do
          @volumes << volume
          volume += @options.volume_step
          break if volume > @options.max_volume
        end
      end

      def init_prices
        @prices = []
        price  = @options.min_price
        loop do
          @prices << price
          price += @options.price_step
          break if price > @options.max_price
        end
      end

      # TODO: Make it better!!!
      # TODO: Add Mutex!!!
      def get_order
        return nil if @generated_orders >= @number
        @generated_orders += 1
        {
          side:   %w[sell buy].sample,
          market: @market,
          volume: @volumes.sample.to_s,
          price:  @prices.sample.to_s
        }
      end

      def default_conf
        {
          min_volume:                      1.0,
          max_volume:                      100.0,
          volume_step:                     1.0,
          min_price:                       0.5,
          max_price:                       1.5,
          price_step:                      0.1
        }
      end
    end
  end
end
