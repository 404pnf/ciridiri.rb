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

  it "should redirect from root to index" do
    get '/'
    assert_redirect('/index.html')
  end

  it "should get existent page" do
    page = page_stub
    page.save

    get "#{page.uri}.html"
    assert last_response.ok?
    assert last_response.body.include?(page.title)
  end

  it "should redirect to edit form if page not found" do
    get "/nonexistent.html"
    assert_redirect("/nonexistent.html.e")
  end

  it "should show an empty edit form" do
    get "/nonexistent.html.e"
    assert last_response.ok?
    assert last_response.body.include?("form")
  end

  it "should create a new page" do
    post "/foo.html", :contents => 'fut-fut-fut, freeeeestylo'
    assert_redirect("/foo.html")
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('freeeeestylo')
  end

  it "should edit an existent page" do
    page = page_stub
    page.save

    get "#{page.uri}.html.e"
    assert last_response.ok?
    assert last_response.body.include?("textarea")
    assert last_response.body.include?(page.contents)
  end

  it "should update an existent page" do
    page = page_stub
    page.save

    post "#{page.uri}.html", :contents => "new contents"
    assert_redirect("#{page.uri}.html")
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?("new contents")
  end

  it "should provide the edit link" do
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
