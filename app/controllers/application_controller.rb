class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_category_data
  before_action :set_uploadable
  before_action :signup_enabled?, if: :devise_controller?

  include ActsAsTaggableOn::TagsHelper

  private

    # :reek:FeatureEnvy { enabled: false }
    def set_locale
      I18n.locale = SlideHub::LocaleUtil.locale(request)
    end

    def set_category_data
      @categories = Category.order('id asc')
    end

    def set_uploadable
      @uploadable = user_signed_in?
      @uploadable = false if user_signed_in? && !current_user.admin && ApplicationSetting['site.only_admin_can_upload'] == '1'
    end

    def signup_enabled?
      return unless request.get?
      if request.path == '/users/sign_up' && ApplicationSetting['site.signup_enabled'] != '1'
        raise ActionController::RoutingError, 'Not Found'
      end
    end

    # TODO: move to specific controller??
    def configure_permitted_parameters
      actions = [:sign_up, :account_update]
      actions.each do |action|
        devise_parameter_sanitizer.permit(action, keys: [:display_name, :biography, :avatar, :username, :twitter_account])
      end
    end
end
