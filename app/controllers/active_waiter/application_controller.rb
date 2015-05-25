module ActiveWaiter
  class ApplicationController < ActionController::Base
    layout :active_waiter_layout

    before_action :include_active_waiter_helper

    private

      def active_waiter_layout
        ActiveWaiter.configuration.layout
      end

      def include_active_waiter_helper
        _helpers.module_eval { include ActiveWaiter.configuration.helper } if ActiveWaiter.configuration.helper
      end
  end
end
