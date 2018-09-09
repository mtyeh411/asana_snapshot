require 'logger'

class AsanaSnapshot::Configuration
  attr_accessor :logger, :token, :base_dir, :persistence

  def initialize
    @logger       = Logger.new STDOUT
    @token        = nil
    @base_dir     = Dir.pwd
    @persistence  = {
      adapter: :git
    }
  end
end
