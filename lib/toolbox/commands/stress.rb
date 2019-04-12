module Toolbox::Commands
  class Stress < Clamp::Command
    parameter "auditor", "component for stress testing",
              attribute_name: :auditor

    # TODO: rescue NameError.
    def execute
      "toolbox/auditors/#{auditor}".camelize.constantize.new.run!
    end
  end
end
