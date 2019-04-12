module Toolbox
  module Injectors
    Dir.glob(File.expand_path("injectors/*/*.rb", __dir__)).each do |path|
      require path
    end
  end
end
