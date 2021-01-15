# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  private

  def set_page
    @page = Page.find_or_create_by(url_param)
  end

  def url_param
    params.permit(:url)
  end
end
