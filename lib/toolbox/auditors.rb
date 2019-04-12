module Toolbox
  module Auditors
    Dir.glob(File.expand_path("auditors/*.rb", __dir__)).each do |path|
      require path
    end
  end
end
