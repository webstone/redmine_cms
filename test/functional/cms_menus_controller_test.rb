require File.expand_path('../../test_helper', __FILE__)

class CmsMenusControllerTest < ActionController::TestCase
  fixtures :users, :cms_menus

  RedmineCMS::TestCase.create_fixtures([:cms_menus])

  def setup
    @controller = CmsMenusController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_index
    @request.session[:user_id] = 1
    get :index
    assert_redirected_to :controller => "pages", :action => 'index', :tab => 'cms_menus'
  end

  def test_new_for_admin
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select "#cms_menu_name", 1 
    assert_select "#cms_menu_caption", 1 
    assert_select "#cms_menu_path", 1 
    assert_select "#cms_menu_position", 1 
    assert_select "#cms_menu_status_id", 1 
    assert_select "#cms_menu_visibility", 1 
    assert_select "#cms_menu_menu_type", 1 
  end

  def test_new_for_non_admin
    @request.session[:user_id] = 3
    get :new
    assert_response :forbidden
  end

  def test_update_for_admin
    @request.session[:user_id] = 1
    menu = CmsMenu.find(1)
    new_name = "updated_name"
    new_caption = "changed caption"
    new_status = 0
    put :update, :id => menu, :cms_menu => {
      :name => new_name,
      :caption => new_caption,
      :status_id => new_status
    }
    menu.reload
    assert_equal new_name, menu.name
    assert_equal new_caption, menu.caption
    assert_equal new_status, menu.status_id
  end

  def test_update_for_non_admin
    @request.session[:user_id] = 3
    menu = CmsMenu.find(1)
    new_name = "updated_name"
    new_caption = "changed caption"
    new_status = 0
    put :update, :id => menu, :cms_menu => {
      :name => new_name,
      :caption => new_caption,
      :status_id => new_status
    }
    menu.reload
    assert_not_equal new_name, menu.name
    assert_not_equal new_caption, menu.caption
    assert_not_equal new_status, menu.status_id
  end

  def test_create_for_admin
    @request.session[:user_id] = 1
    assert_difference 'CmsMenu.count' do
      put :create, :cms_menu => {
        :name => "add_new_name_item",
        :caption => "caption for new menu item",
        :status_id => 1,
        :path => "/new_item_in_menu",
        :position => 1
      }
    end
    assert_template :edit
    assert_match ::I18n.t(:notice_successful_create), @response.body
  end

  def test_remove_menu
    @request.session[:user_id] = 1
    assert_difference 'CmsMenu.count', -1 do
      post :destroy, :id => cms_menus(:menu_001)
    end
    assert_redirected_to :controller => 'pages', :action => 'index', :tab => "cms_menus"
  end

  def test_remove_menu_for_non_admin
    @request.session[:user_id] = 3
    assert_no_difference 'CmsMenu.count' do
      post :destroy, :id => cms_menus(:menu_001)
    end
  end

end
