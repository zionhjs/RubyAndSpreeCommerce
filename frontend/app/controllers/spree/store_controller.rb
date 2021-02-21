module Spree
  class StoreController < Spree::BaseController
    include Spree::Core::ControllerHelpers::Order
    helper 'spree/locale'
    helper 'spree/currency'

    skip_before_action :verify_authenticity_token, only: :ensure_cart, raise: false

    def account_link
      render partial: 'spree/shared/link_to_account'
      fresh_when(try_spree_current_user)
    end

    def cart_link
      render partial: 'spree/shared/link_to_cart'
      fresh_when(simple_current_order)
    end

    def api_tokens
      render json: {
        order_token: simple_current_order&.token,
        oauth_token: current_oauth_token&.token
      }
    end

    def ensure_cart
      render json: current_order(create_order_if_necessary: true) # force creation of order if doesn't exists
    end

    protected

    def config_locale
      Spree::Frontend::Config[:locale]
    end

    def store_etag
      [
        current_store,
        current_currency,
        I18n.locale
      ]
    end

    def store_last_modified
      (current_store.updated_at || Time.current).utc
    end
  end
end
