require 'test_helper'

class ConfigurationTest < Minitest::Test
  def test_configuration_defaults
    assert_nil ActiveWaiter.configuration.layout
  end

  def test_configuration_layout
    ActiveWaiter.configure do |config|
      config.layout = 'layouts/application'
    end

    assert_equal "layouts/application", ActiveWaiter.configuration.layout
  ensure
    ActiveWaiter.configuration = nil
  end
end
