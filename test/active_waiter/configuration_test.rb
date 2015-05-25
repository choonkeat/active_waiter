require 'test_helper'

class ConfigurationTest < Minitest::Test
  def teardown
    ActiveWaiter.configuration = nil
  end

  def test_configuration_defaults
    assert_equal "active_waiter/layouts/application", ActiveWaiter.configuration.layout
    assert_nil ActiveWaiter.configuration.helper
  end

  def test_configuration_layout
    ActiveWaiter.configure do |config|
      config.layout = 'layouts/application'
    end

    assert_equal "layouts/application", ActiveWaiter.configuration.layout
  end

  def test_configuration_helper
    ActiveWaiter.configure do |config|
      config.helper = Rails.application.routes.url_helpers
    end

    assert_equal Rails.application.routes.url_helpers, ActiveWaiter.configuration.helper
  end
end
