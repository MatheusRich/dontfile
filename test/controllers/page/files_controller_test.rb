# frozen_string_literal: true

require 'test_helper'

class Page::FilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = Page.new(
      url: 'page_url',
      content: 'Some content'
    )
    @page.file.attach(
      io: File.open('public/dontfile.png'),
      filename: 'dontfile.png'
    )
    @page.save!
  end

  test 'should create file' do
    other_page = Page.create!(
      url: 'other-page-url',
      content: 'Some content'
    )

    assert_not other_page.file.attached?
    post update_page_file_path(other_page.url), params: {
      page: {
        file: fixture_file_upload('public/dontfile.png')
      }
    }
    other_page.reload

    assert other_page.file.attached?
  end

  test 'should update file' do
    post create_page_file_path(@page.url), params: {
      page: {
        file: fixture_file_upload('public/robots.txt', 'text/txt')
      }
    }
    @page.reload

    assert_equal 'text/txt', @page.file.blob.content_type
  end

  test 'should not upload file bigger than max size allowed' do
    other_page = Page.create!(
      url: 'other-page-url',
      content: 'Some content'
    )
    assert_not other_page.file.attached?

    reset_max_file_size_constant
    assert_equal 0, Page::MAX_FILE_SIZE

    patch "/#{other_page.url}/file", params: {
      page: {
        url: "/#{other_page.url}",
        file: fixture_file_upload('public/dontfile.png', 'image/png')
      }
    }
    assert_response :not_acceptable
    other_page.reload

    assert_not other_page.file.attached?

    reset_max_file_size_constant(100.0.megabytes)
    assert_equal 100.0.megabytes, Page::MAX_FILE_SIZE
  end

  test 'should delete file' do
    assert_difference 'ActiveStorage::Attachment.count', -1 do
      delete delete_page_file_path(@page.url)
    end

    assert_not @page.reload.file.attached?
  end
end
