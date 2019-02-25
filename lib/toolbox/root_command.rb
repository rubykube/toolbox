require_relative "stress/root_command"

module Toolbox
  class RootCommand < Clamp::Command
    subcommand "stress", "Run stress test of component", Stress::RootCommand
  end
end

