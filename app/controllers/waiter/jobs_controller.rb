require_dependency "waiter/application_controller"

module Waiter
  class JobsController < ApplicationController
    def show
      data = Waiter.read(params[:id])
      return on_not_found(data) unless data.respond_to?(:[])
      return on_error(data)     if data[:error]
      return on_redirect(data)  if data[:redirect_to]
      return on_link_to(data)   if data[:link_to]
      return on_progress(data)  if data[:percentage]
    end

    protected

      def on_not_found(data)
        raise ActionController::RoutingError.new('Not Found')
      end

      def on_error(data)
        render template: "waiter/jobs/error", status: :internal_server_error, locals: data
      end

      def on_redirect(data)
        redirect_to data[:redirect_to]
      end

      def on_link_to(data)
        render template: "waiter/jobs/link_to",  locals: data
      end

      def on_progress(data)
        render template: "waiter/jobs/progress", locals: data
      end
  end
end
