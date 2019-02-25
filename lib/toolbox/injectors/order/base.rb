module Toolbox::Injectors
  module Order
    class Base
      attr_reader :options, :orders_number
      def initialize(options)
        @options = options.merge!(default_conf.except(*options.keys))
        binding.pry
        @number = options.number
        binding.pry
        @market = options.market
      end

      def default_conf; {}; end
    end
  end
end
