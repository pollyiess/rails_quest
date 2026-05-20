class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  private

  def set_locale
    I18n.locale = extract_locale_from_session
  end

  def extract_locale_from_session
    locale = session[:locale].presence&.to_sym
    return locale if I18n.available_locales.include?(locale)

    I18n.default_locale
  end
end
