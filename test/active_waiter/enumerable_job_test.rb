require 'test_helper'

class LoopJob < ActiveJob::Base
  include ActiveWaiter::EnumerableJob

  attr_accessor :enumerable, :items_count, :suppress_exceptions

  def before(count, suppress: false)
    @suppress_exceptions = suppress
    @items_count = count
    @enumerable = count.times
    @result = ["before"]
  end

  def foreach(item)
    @result.push(item * 2)
  end

  def after
    @result.push "after"
  end

  def result
    @result
  end
end

class ActiveWaiter::EnumerableJobTest < Minitest::Test
  include ActiveJob::TestHelper

  def test_enumerate_with_progress
    ActiveWaiter.stub :next_uuid, uid = "hello" do
      expected_progress = [
        [uid, {}],
        [uid, { percentage: 20.0, error: nil }],
        [uid, { percentage: 40.0, error: nil }],
        [uid, { percentage: 60.0, error: nil }],
        [uid, { percentage: 80.0, error: nil }],
        [uid, { percentage: 99,   error: nil }], # last foreach, should be `100` but ActiveWaiter::Job allows max `99`
        [uid, { percentage: 100,  link_to: ["before", 0, 2, 4, 6, 8, "after"] }], # `100` reported by ActiveWaiter::Job#around_perform
      ]
      validates_each_write = proc { |*args| assert_equal expected_progress.shift, args; }
      ActiveWaiter.stub :write, validates_each_write do |*args|
        perform_enqueued_jobs do
          assert_equal uid, ActiveWaiter.enqueue(LoopJob, 5)
        end
      end
    end
  end

  def test_error
    ActiveWaiter.stub :next_uuid, uid = "hello" do
      perform_enqueued_jobs do
        assert_raises NoMethodError do
          assert_equal uid, ActiveWaiter.enqueue(LoopJob, nil, suppress: false)
        end
        assert_equal Hash(error: "undefined method `times' for nil:NilClass"), ActiveWaiter.read(uid)
      end
    end
  end

  def test_suppressed_error
    ActiveWaiter.stub :next_uuid, uid = "hello" do
      perform_enqueued_jobs do
        assert_equal uid, ActiveWaiter.enqueue(LoopJob, nil, suppress: true)
        assert_equal Hash(error: "undefined method `times' for nil:NilClass"), ActiveWaiter.read(uid)
      end
    end
  end
end
