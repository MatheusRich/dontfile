# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :set_page

  def index; end

  def show
    respond_to do |format|
      format.zip { download_zip_file }
      format.any(:html, :json) { render 'show' }
    end
  end

  def update
    respond_to do |format|
      if @page.update(update_page_params)
        format.any(:html, :json) { render 'show' }
      else
        format.html { render 'show', status: :not_acceptable }
        format.json { render json: @page.errors, status: :not_acceptable }
      end
    end
  end

  private

  def update_page_params
    params.require(:page).permit(:content, :url, :file)
  end

  def download_zip_file
    zip_filename = "tmp/#{@page.url}.zip"

    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("#{@page.url}.txt") { |f| f.write @page.content }

      if @page.file.attached?
        filepath = ActiveStorage::Blob.service.path_for @page.file.key
        zipfile.add(@page.file.filename.to_s, filepath)
      end
    end

    send_file zip_filename
  end
end
