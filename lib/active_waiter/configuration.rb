module ActiveWaiter
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(configuration)
    @configuration = configuration
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :layout, :helper

    def initialize
      @layout = "active_waiter/layouts/application".freeze
      @helper = nil
    end
  end
end
