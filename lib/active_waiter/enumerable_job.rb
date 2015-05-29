module ActiveWaiter::EnumerableJob
  extend ActiveSupport::Concern

  included do
    include ActiveWaiter::Job
  end

  def perform(*args)
    before(*args)
    enumerable.each_with_index do |item, index|
      foreach(item)
      update_active_waiter(percentage: (100 * (index+1.to_f) / items_count))
    end
    after
    result
  end

  def before(*_args); end # called once with arguments of `perform`

  def enumerable; [] end # an Enumerable interface

  def items_count; 1 end # called 0-n times, depending on enumerable

  def foreach(_item); end # called 0-n times, depending on enumerable

  def after;         end # called once

  def result;        end # called once
end
