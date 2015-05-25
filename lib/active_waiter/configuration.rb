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
    attr_accessor :layout

    def initialize
      @layout = "active_waiter/layouts/application".freeze
    end
  end
end
