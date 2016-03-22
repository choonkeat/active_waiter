module ActiveWaiter
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :layout, :store

    def initialize
      @store = ActiveWaiter::Store.new
    end
  end
end
