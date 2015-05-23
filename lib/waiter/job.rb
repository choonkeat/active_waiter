module Waiter::Job
  extend ActiveSupport::Concern

  included do
    around_perform do |job, block|
      @waiter_options = job.arguments.shift
      begin
        key = (self.class.try(:download?) ? :link_to : :redirect_to)
        ::Waiter.write(@waiter_options[:uid], {
          percentage: 100,
          key => block.call,
        })
      rescue Exception
        ::Waiter.write(@waiter_options[:uid], {
          error: $!.to_s,
        })
        raise
      end
    end
  end

  def update_waiter(percentage: nil, error: nil)
    ::Waiter.write(@waiter_options[:uid], {
      percentage: percentage && [percentage, 99].min,
      error: error,
    })
  end
end
