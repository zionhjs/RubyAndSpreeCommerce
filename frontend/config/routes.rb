Spree::Core::Engine.add_routes do
  root to: 'home#index'

  resources :products, only: [:index, :show]

  get '/locales', to: 'locale#index', as: :locales
  get '/locale/set', to: 'locale#set', as: :set_locale
  get '/currency/set', to: 'currency#set', as: :set_currency

  # non-restful checkout stuff
  patch '/checkout/update/:state', to: 'checkout#update', as: :update_checkout
  get '/checkout/:state', to: 'checkout#edit', as: :checkout_state
  get '/checkout', to: 'checkout#edit', as: :checkout

  get '/orders/populate', to: 'orders#populate_redirect'

  resources :orders, except: [:index, :new, :create, :destroy] do
    post :populate, on: :collection
  end

  resources :addresses, except: [:show]

  get '/cart', to: 'orders#edit', as: :cart
  patch '/cart', to: 'orders#update', as: :update_cart
  put '/cart/empty', to: 'orders#empty', as: :empty_cart

  # route globbing for pretty nested taxon and product paths
  get '/t/*id', to: 'taxons#show', as: :nested_taxons
  get '/product_carousel/:id', to: 'taxons#product_carousel'

  get '/content/cvv', to: 'content#cvv', as: :cvv
  get '/content/test', to: 'content#test'
  get '/cart_link', to: 'store#cart_link', as: :cart_link
  get '/account_link', to: 'store#account_link', as: :account_link

  get '/api_tokens', to: 'store#api_tokens'
  post '/ensure_cart', to: 'store#ensure_cart'
  get '/products/:id/related', to: 'products#related'
end
