require 'test_helper'
require 'rack/test'
require 'sinatra'
require 'ciridiri'

set :environment, :test
set :root, File.expand_path("../", File.dirname(__FILE__))

class CiridiriTest < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  def test_it_should_redirect_from_root_to_index
    get '/'
    assert_redirect('/index.html')
  end

  def test_it_should_get_existent_page
    page = page_stub
    page.save

    get "#{page.uri}.html"
    assert last_response.ok?
    assert last_response.body.include?(page.title)
  end

  def test_it_should_redirect_to_edit_form_if_page_not_found
    get "/nonexistent.html"
    assert_redirect("/nonexistent.html.e")
  end

  def test_it_should_show_an_empty_edit_form
    get "/nonexistent.html.e"
    assert last_response.ok?
    assert last_response.body.include?("form")
  end

  def test_it_should_create_a_new_page
    post "/foo.html", :contents => 'fut-fut-fut, freeeeestylo'
    assert_redirect("/foo.html")
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('freeeeestylo')
  end

  def test_it_should_edit_an_existent_page
    page = page_stub
    page.save

    get "#{page.uri}.html.e"
    assert last_response.ok?
    assert last_response.body.include?("textarea")
    assert last_response.body.include?(page.contents)
  end

  def test_it_should_update_an_existent_page
    page = page_stub
    page.save

    post "#{page.uri}.html", :contents => "new contents"
    assert_redirect("#{page.uri}.html")
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("new contents")
  end

  def test_it_should_provide_the_edit_link
    page = page_stub
    page.save

    get "#{page.uri}.html"
    assert last_response.ok?
    assert last_response.body.include?("edit-link")
    assert last_response.body.include?("#{page.uri}.html.e")
  end

  protected
  def assert_redirect(uri)
    assert last_response.redirect?
    assert_equal last_response.headers['Location'], uri
  end

end
