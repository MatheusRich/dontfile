# frozen_string_literal: true

class Page::FilesController < ApplicationController
  before_action :set_page

  def show
    respond_to do |format|
    end
  end

  def create
    respond_to do |format|
      if @page.update(file_param)
        format.json { render 'pages/show' }
      else
        format.json { render json: @page.errors, status: :not_acceptable }
      end
    end
  end

  def update
    respond_to do |format|
    end
  end

  def delete
    @page.file.purge

    respond_to do |format|
      format.html { redirect_back(fallback_location: 'show') }
      format.json { render 'pages/show' }
    end
  end

  private

  def set_page
    @page = Page.find_or_create_by(url_param)
  end

  def file_param
    params.require(:page).permit(:file)
  end
end
