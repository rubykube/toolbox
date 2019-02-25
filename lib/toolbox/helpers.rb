module Toolbox
  module Helpers
    Dir.glob(File.expand_path("helpers/*.rb", __dir__)).each do |path|
      require path
    end
  end
end
