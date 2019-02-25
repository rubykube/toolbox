Dir.glob(File.expand_path("commands/*.rb", __dir__)).each do |path|
  require path
end

module Toolbox
  class RootCommand < Clamp::Command
    subcommand "stress", "Run stress test of component", Commands::Stress
  end
end

