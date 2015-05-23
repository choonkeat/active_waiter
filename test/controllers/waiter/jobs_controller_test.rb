require 'test_helper'
require 'minitest/mock'

class RedirectJob < ActiveJob::Base
  include Waiter::Job

  def perform
    "http://other.com/12345"
  end
end

class DownloadJob < RedirectJob
  def self.download?
    true
  end
end

class Waiter::JobsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @routes = Waiter::Engine.routes
  end

  def teardown
    clear_enqueued_jobs
  end

  def test_show_non_existent
    assert_raises ActionController::RoutingError do
      get '/waiter', id: "nosuchjob"
    end
  end

  def test_show_started
    Waiter.stub :next_uuid, uid do
      assert_equal uid, Waiter.enqueue(DownloadJob)
      get '/waiter', id: uid
      assert_equal 200, status
      assert_match "Please wait", document_root_element.to_s
    end
  end

  def test_show_error
    Waiter.write(uid, error: "oops")
    get '/waiter', id: uid
    assert_equal 500, status
    assert_match "oops", document_root_element.to_s
  end

  def test_show_progress
    Waiter.write(uid, percentage: 42)
    get '/waiter', id: uid
    assert_equal 200, status
    assert_match "42%", document_root_element.to_s
  end

  def test_show_completed
    Waiter.stub :next_uuid, uid do
      perform_enqueued_jobs do
        assert_equal uid, Waiter.enqueue(DownloadJob)
        get '/waiter', id: uid
        assert_equal 200, status
        link = document_root_element.css("a[href='http://other.com/12345']").first
        assert link, "missing hyperlink to returned value"
        assert_match "Click", link.text
      end
    end
  end

  def test_show_completed_redirect
    Waiter.stub :next_uuid, uid do
      perform_enqueued_jobs do
        assert_equal uid, Waiter.enqueue(RedirectJob)
        get '/waiter', id: uid
        assert_equal 302, status
        assert_equal "http://other.com/12345", response.location
      end
    end
  end

  private

    def uid
      "hello"
    end
end
