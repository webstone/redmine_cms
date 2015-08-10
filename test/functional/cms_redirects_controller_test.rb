require File.expand_path('../../test_helper', __FILE__)

class CmsRedirectsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @controller = CmsRedirectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    Setting.plugin_redmine_cms[:redirects] = []
    @redirect1 = CmsRedirect.new(
      :source_path => '/source_path',
      :destination_path => '/destination_path'
    )
    @redirect1.save

    @redirect2 = CmsRedirect.new(
      :source_path => '/source_path2',
      :destination_path => '/destination_path2'
    )
    @redirect2.save
  end

  def test_index
    @request.session[:user_id] = 1
    get :index
    assert_redirected_to :controller => "cms_settings", :action => 'index', :tab => 'cms_redirects'
    @request.session[:user_id] = 3
    get :index
    assert_response :forbidden
  end

   def test_new_for_admin
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select "#cms_redirect_source_path", 1 
    assert_select "#cms_redirect_destination_path", 1 
  end

  def test_new_for_non_admin
    @request.session[:user_id] = 3
    get :new
    assert_response :forbidden
  end

  def test_update
    @request.session[:user_id] = 1
    put :update, :id => @redirect1, :cms_redirect => {
      :source_path => "/new_source_path",
      :destination_path => "/new_dest_path"
    }
    assert_redirected_to cms_redirects_path
    found_changed_redirect = false
    CmsRedirect.all.each do |rd|
      found_changed_redirect = rd.source_path == "/new_source_path" && rd.destination_path == "/new_dest_path"
    end
    assert found_changed_redirect, "Didn't find changed redirect"      
  end

  def test_create
    @request.session[:user_id] = 1
    put :create, :cms_redirect => {
      :source_path => "/new_source_path",
      :destination_path => "/new_dest_path"
    }
    assert_redirected_to cms_redirects_path
    found_changed_redirect = false
    CmsRedirect.all.each do |rd|
      found_changed_redirect = (rd.source_path == "/new_source_path" && rd.destination_path == "/new_dest_path")
    end
    assert found_changed_redirect, "Didn't find created redirect"      
  end

  def test_fail_create
    @request.session[:user_id] = 1
    put :create, :cms_redirect => {
      :source_path => "/bad source_path",
      :destination_path => "/new_dest_path"
    }
    assert_template :new
    found_changed_redirect = false
    CmsRedirect.all.each do |rd|
      found_changed_redirect = (rd.source_path == "/bad source_path" && rd.destination_path == "/new_dest_path")
    end
    assert !found_changed_redirect, "found created redirect"      
  end

end
