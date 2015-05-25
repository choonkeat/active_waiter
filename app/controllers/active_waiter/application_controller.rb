module ActiveWaiter
  class ApplicationController < ActionController::Base
    layout :active_waiter_layout

    private

      def active_waiter_layout
        ActiveWaiter.configuration.layout
      end
  end
end
