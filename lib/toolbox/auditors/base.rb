module Toolbox::Auditors
  class Base

    attr_reader :config

    # TODO: Custom config file.
    def initialize
      @config = Config.load_and_set_settings(default_conf_file)
      puts @config
    end

    def default_conf_file
      File.join(TOOLBOX_ROOT, "config", "#{self.class.name.demodulize.downcase}.yml")
    end

    def run!
      puts 'do nothing'
    end
  end
end
