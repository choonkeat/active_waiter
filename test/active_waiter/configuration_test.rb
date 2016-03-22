require 'test_helper'

class TestStore
  def initialize
    @test_hash = {}
  end

  def write(uid, value)
    @test_hash[uid] = value
  end

  def read(uid)
    @test_hash[uid]
  end
end

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

  def test_configuration_store
    test_store = TestStore.new
    ActiveWaiter.configure do |config|
      config.store = test_store
    end

    ActiveWaiter.write("abcdef", "test")
    assert_equal "test", test_store.read("abcdef")
  ensure
    ActiveWaiter.configuration = nil
  end
end
