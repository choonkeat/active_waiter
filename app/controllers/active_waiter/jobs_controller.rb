require_dependency "active_waiter/application_controller"

module ActiveWaiter
  class JobsController < ApplicationController
    def show
      data = ActiveWaiter.read(params[:id])
      return on_not_found(data) unless data.respond_to?(:[])
      return on_error(data)     if data[:error]
      return on_link_to(data)   if data[:link_to] && params[:download]
      return on_redirect(data)  if data[:link_to]
      return on_progress(data)  if data[:percentage]
    end

    protected

      def on_not_found(_data)
        case retries = params[:retries].to_i
        when 0..9
          @retries = retries + 1
        else
          raise ActionController::RoutingError.new('Not Found')
        end
      end

      def on_error(data)
        render template: "active_waiter/jobs/error", status: :internal_server_error, locals: data
      end

      def on_redirect(data)
        redirect_to data[:link_to]
      end

      def on_link_to(data)
        render template: "active_waiter/jobs/link_to",  locals: data
      end

      def on_progress(data)
        render template: "active_waiter/jobs/progress", locals: data
      end
  end
end
