# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = Page.create(
      url: 'page_url',
      content: 'Some content'
    )
  end

  test 'should route show to existing pages' do
    assert_routing "/#{@page.url}",
                   controller: 'pages',
                   action: 'show',
                   url: @page.url
  end

  test 'should route show to new pages' do
    assert_routing '/new_page',
                   controller: 'pages',
                   action: 'show',
                   url: 'new_page'
  end

  test 'should route update action' do
    assert_routing(
      {
        method: 'patch',
        path: "/#{@page.url}"
      },
      { controller: 'pages',
        action: 'update',
        url: @page.url }
    )
  end

  test 'should create page' do
    assert_difference('Page.count') do
      get '/some_page', params: {
        page: {
          content: 'Some content',
          url: 'some_page'
        }
      }
    end

    assert_template :show
  end

  test 'should show page' do
    get "/#{@page.url})"
    assert_response :success
  end

  test 'should update page' do
    patch "/#{@page.url}", params: {
      page: {
        url: "/#{@page.url}",
        content: 'New content'
      }
    }
    @page.reload

    assert_equal @page.content, 'New content'
  end

  test 'should upload file' do
    assert_not @page.file.attached?
    patch "/#{@page.url}", params: {
      page: {
        url: "/#{@page.url}",
        file: fixture_file_upload('public/dontfile.png', 'image/png')
      }
    }
    @page.reload

    assert @page.file.attached?
  end

  test 'should create a zip file' do
    req_url = "#{@page.url}.zip"
    expected_zip_file = "tmp/#{req_url}"

    get "/#{req_url}"

    assert File.file?(expected_zip_file)
    File.delete expected_zip_file
  end

  test 'should download a zip file' do
    req_url = "#{@page.url}.zip"
    expected_zip_file = "tmp/#{req_url}"

    get "/#{req_url}"

    assert_equal @response.header['Content-Type'], 'application/zip'
    assert_equal @response.header['Content-Disposition'],
                 "attachment; filename=\"#{req_url}\"; filename*=UTF-8''#{req_url}"

    File.delete expected_zip_file
  end

  test 'should create a zip file with appropriate content' do
    image_filename = 'dontfile.png'

    @page.file.attach(
      io: File.open("public/#{image_filename}"),
      filename: image_filename
    )
    @page.save!

    req_url = "#{@page.url}.zip"
    expected_zip_file = "tmp/#{req_url}"

    get "/#{req_url}"

    Zip::File.open(expected_zip_file) do |zip_file|
      files = zip_file.map(&:name)
      assert_equal files, ["#{@page.url}.txt", image_filename]
    end

    File.delete expected_zip_file
  end
end
