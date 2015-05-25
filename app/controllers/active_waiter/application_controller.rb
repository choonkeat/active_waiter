module ActiveWaiter
  class ApplicationController < ActionController::Base
    layout "layouts/application"
    helper Rails.application.routes.url_helpers
  end
end
