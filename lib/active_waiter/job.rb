module ActiveWaiter::Job
  extend ActiveSupport::Concern

  included do
    around_perform do |job, block|
      @active_waiter_options = job.arguments.shift
      begin
        key = (self.class.try(:download?) ? :link_to : :redirect_to)
        ::ActiveWaiter.write(@active_waiter_options[:uid], {
          percentage: 100,
          key => block.call,
        })
      rescue Exception
        ::ActiveWaiter.write(@active_waiter_options[:uid], {
          error: $!.to_s,
        })
        raise
      end
    end
  end

  def update_active_waiter(percentage: nil, error: nil)
    ::ActiveWaiter.write(@active_waiter_options[:uid], {
      percentage: percentage && [percentage, 99].min,
      error: error,
    })
  end
end
