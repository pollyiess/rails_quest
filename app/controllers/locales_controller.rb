class LocalesController < ApplicationController
  def update
    locale = params[:locale].presence&.to_sym
    session[:locale] = I18n.available_locales.include?(locale) ? locale : I18n.default_locale

    redirect_back fallback_location: root_path
  end
end
