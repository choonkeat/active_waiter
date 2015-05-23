require 'test_helper'

class DummyJob < ActiveJob::Base
  include Waiter::Job

  def perform(one, two, three: 3, four: [1,2,3,4])
    [one, two, three, four].to_json
  end
end

class Waiter::JobTest < Minitest::Test
  include ActiveJob::TestHelper

  def teardown
    clear_enqueued_jobs
  end

  def test_normal
    assert_equal expected_return_value, DummyJob.new.perform(*arguments)
  end

  def test_waiter_enqueue
    Waiter.stub :next_uuid, uid = "hello" do
      perform_enqueued_jobs do
        assert_equal uid, Waiter.enqueue(DummyJob, *arguments)
        assert_equal Hash(percentage: 100, redirect_to: expected_return_value), Waiter.read(uid)
      end
    end
  end

  private

    def arguments
      ['a', 'b', four: ['a', 'b', 'c']]
    end

    def expected_return_value
      ['a', 'b', 3, ['a', 'b', 'c']].to_json
    end
end
