class AsanaSnapshot::Persistence
  extend Forwardable

  attr_reader :adapter

  def_delegators :adapter, :mark_for_save, :save

  def initialize(adapter: :git)
    case adapter.to_sym
    when :git
      require 'asana_snapshot/persistence/git'
      @adapter = AsanaSnapshot::Persistence::GitAdapter.new
    else
      raise ArgumentError, "Unknown persistence adapter: #{adapter}"
    end
  end
end
