module Toolbox
  module Clients
    Dir.glob(File.expand_path("clients/*.rb", __dir__)).each do |path|
      require path
    end
  end
end

