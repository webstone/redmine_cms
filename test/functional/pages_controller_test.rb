require File.expand_path('../../test_helper', __FILE__)

class PagesControllerTest < ActionController::TestCase
  
  fixtures :users, :pages

  RedmineCMS::TestCase.create_fixtures(:pages)

  def setup
    # RedmineCMS::TestCase.prepare

    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_show_page
    @request.session[:user_id] = 1
    page = pages(:page_001)
    get :show, :id => page.name
    assert_response :success
    assert_template RedmineCms.layout
    assert_match page.content, @response.body
  end

  def test_privileges_for_show_page
    @request.session[:user_id] = 3
    page = pages(:page_003)
    get :show, :id => page.name
    assert_response :forbidden
  end

  def test_anonymus_access
    @request.session[:user_id] = 6
    get :show, :id => pages(:page_002) #public page
    assert_response :success
    get :show, :id => pages(:page_001) #only for logged user
    assert_response :redirect
    get :show, :id => pages(:page_003) #not active page
    assert_response :redirect
  end

  def test_new_page
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select "#page_name", 1
    assert_select "#page_title", 1
    assert_select "#page_project_id", 1
    assert_select "#page_visibility", 1
    assert_select "#page_keywords", 1
    assert_select "#page_content", 1
    assert_select "#show_content_edit", 1
    assert_select "#attachments_form", 1
  end

end
