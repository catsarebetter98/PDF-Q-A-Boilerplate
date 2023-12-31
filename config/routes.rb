Rails.application.routes.draw do
  get 'fetch_question/:id', to: 'questions#show', as: 'question'
  post '/ask', to: 'questions#ask'

  namespace :api do
  end
  # all other routes will be load our React application
  # this route definition matches:
  # - *path: all paths not matched by one of the routes defined above
  # - constraints:
  #   - !req.xhr?: it's not a XHR (fetch) request
  #   - req.format.html?: it's a request for a HTML document
  get "*path", to: "fallback#index", constraints: ->(req) { !req.xhr? && req.format.html? }
end
