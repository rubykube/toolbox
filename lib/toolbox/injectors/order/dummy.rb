require "toolbox/helpers/configuration"
require_relative "base"

module Toolbox::Injectors
  module Order
    class Dummy < Base

      include Toolbox::Helpers::Configuration

      def initialize(config)
        super
        @number = @config.number
        @markets = @config.markets
      end

      def prepare!
        configure_volumes
        configure_prices
        init_volumes
        init_prices
        generate_orders
      end

      def init_volumes
        @volumes = []
        volume = @min_volume
        loop do
          @volumes << volume
          volume += @volume_step
          break if volume > @max_volume
        end
      end

      def init_prices
        @prices = []
        price = @min_price
        loop do
          @prices << price
          price += @price_step
          break if price > @max_price
        end
      end

      def pop
        return nil if @queue.empty?
        @queue.pop
      end

      def generate_order
        { side:   %w[sell buy].sample,
          market: @markets.sample,
          volume: @volumes.sample.to_s,
          price:  @prices.sample.to_s }
      end

      def generate_orders
        @queue = Queue.new
        @number.times do
          @queue << generate_order
        end
      end

      def default_conf
        { min_volume:  1.0,
          max_volume:  100.0,
          volume_step: 1.0,
          min_price:   0.5,
          max_price:   1.5,
          price_step:  0.1 }
      end
    end
  end
end
