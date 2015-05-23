Waiter::Engine.routes.draw do
  get '/:id' => 'jobs#show'
  root to: 'jobs#show'
end
