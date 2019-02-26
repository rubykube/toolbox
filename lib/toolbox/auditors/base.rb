require "toolbox/helpers/configuration"
require "toolbox/injectors"

module Toolbox::Auditors
  class Base

    attr_reader :config

    # TODO: Ability to customize config file with clamp option.
    #       Now default config file is config/#{auditor_name}.yml.
    def initialize
      @config = Config.load_and_set_settings(default_conf_file)
      @config.merge!(default_conf.except(*@config.keys))
    end

    # Subclasses implements this method.
    def run!
      method_not_implemented
    end

    protected

    def auditor_name
      self.class.name.demodulize.downcase
    end

    def default_conf_file
      File.join(TOOLBOX_ROOT, "config", "#{auditor_name}.yml")
    end

    def default_conf; {}; end
  end
end
