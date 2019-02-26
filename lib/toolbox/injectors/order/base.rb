module Toolbox::Injectors
  module Order
    class Base
      attr_reader :config, :number
      def initialize(config)
        @config = config.merge!(default_conf.except(*config.keys))
        @number = config.number
        @market = config.market
      end

      def default_conf; {}; end
    end
  end
end
