module Toolbox::Injectors
  module Order
    class Base
      attr_reader :config, :number
      def initialize(config)
        @config = config.merge!(default_conf.except(*config.keys))
      end

      def default_conf; {}; end
    end
  end
end
