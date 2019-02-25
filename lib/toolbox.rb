require "toolbox/version"
# require "pry-byebug"
# require "active_support/all"
require 'bundler'
Bundler.require :default

module Toolbox
  require_relative "toolbox/auditors"
  require_relative "toolbox/error"
  require_relative "toolbox/helpers"
  require_relative "toolbox/root_command"
end
