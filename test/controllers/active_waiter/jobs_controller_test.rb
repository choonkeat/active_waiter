require 'test_helper'
require 'minitest/mock'

class RedirectJob < ActiveJob::Base
  include ActiveWaiter::Job

  def perform
    "http://other.com/12345"
  end
end

class ActiveWaiter::JobsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @routes = ActiveWaiter::Engine.routes
  end

  def teardown
    clear_enqueued_jobs
  end

  def test_show_non_existent
    do_request id: "nosuchjob", download: 0
    assert_equal 200, status
    assert_match "/active_waiter/nosuchjob?download=0&retries=1".to_json, response.body
  end

  def test_show_non_existent_retries_9
    do_request id: "nosuchjob", download: 1, retries: "9"
    assert_equal 200, status
    assert_match "/active_waiter/nosuchjob?download=1&retries=10".to_json, response.body
  end

  def test_show_non_existent_retries_10
    assert_raises ActionController::RoutingError do
      do_request id: "nosuchjob", download: 2, retries: "10"
    end
  end

  def test_show_started
    ActiveWaiter.stub :next_uuid, uid do
      assert_equal uid, ActiveWaiter.enqueue(RedirectJob)
      do_request id: uid, retries: "9"
      assert_equal 200, status
      assert_match "Please wait", document_root_element.to_s
      assert_match "/active_waiter/#{uid}".to_json, response.body
    end
  end

  def test_show_error
    ActiveWaiter.write(uid, error: "oops")
    do_request id: uid
    assert_equal 500, status
    assert_match "oops", document_root_element.to_s
  end

  def test_show_progress
    ActiveWaiter.write(uid, percentage: 42)
    do_request id: uid, retries: "9"
    assert_equal 200, status
    assert_match "42%", document_root_element.to_s
    assert_match "/active_waiter/#{uid}".to_json, response.body
  end

  def test_show_completed_download
    ActiveWaiter.stub :next_uuid, uid do
      perform_enqueued_jobs do
        assert_equal uid, ActiveWaiter.enqueue(RedirectJob)
        do_request id: uid, download: 1
        assert_equal 200, status
        link = document_root_element.css("a[href='http://other.com/12345']").first
        assert link, "missing hyperlink to returned value"
        assert_match "Click", link.text
      end
    end
  end

  def test_show_completed_redirect
    ActiveWaiter.stub :next_uuid, uid do
      perform_enqueued_jobs do
        assert_equal uid, ActiveWaiter.enqueue(RedirectJob)
        do_request id: uid
        assert_equal 302, status
        assert_equal "http://other.com/12345", response.location
      end
    end
  end

  def test_configuration_layout
    ActiveWaiter.configure do |config|
      config.layout = 'layouts/application'
    end

    ActiveWaiter.stub :next_uuid, uid do
      assert_equal uid, ActiveWaiter.enqueue(RedirectJob)
      do_request id: uid
      assert_template layout: "layouts/application"
    end
  ensure
    ActiveWaiter.configuration = nil
  end

  private

    def do_request(params)
      get '/active_waiter', params: params
    end

    def uid
      "hello"
    end
end
