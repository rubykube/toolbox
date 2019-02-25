module Toolbox::Auditors
  class Base

    # TODO: Custom config file.
    def initialize
      binding.pry
      @config = Config.load_and_set_settings(default_conf_file)
      puts @config
      # @config = File.exists?()
    end

    def default_conf_file
      File.join(TOOLBOX_ROOT, "config", "#{self.class.name.demodulize.downcase}.yml")
    end

    def run!
      puts 'do nothing'
    end
  end
end
