Rails.application.routes.draw do

  mount Waiter::Engine => "/waiter"
end
