require File.expand_path('../../test_helper', __FILE__)

class CmsVariableControllerTest < ActionController::TestCase
  fixtures :cms_variables

  # RedmineCMS::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_cms).directory + '/test/fixtures/', [:cms_variables])
  RedmineCMS::TestCase.create_fixtures([:cms_variables])
  def setup
    @controller = CmsVariablesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_new
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select 'input#cms_variable_name'
    assert_select 'input#cms_variable_value'
    assert_select 'input[type=?]', 'submit'
  end

  def test_create
    @request.session[:user_id] = 1
    assert_difference 'CmsVariable.count' do 
      post :create,
        :cms_variable => {
          :name => "new_var",
          :value => "value for var"
        }
    end   
  end

  def test_edit
    @request.session[:user_id] = 1
    get :edit, :id => cms_variables(:var001).id
    assert_response :success
    assert_select 'input#cms_variable_name'
    assert_select 'input#cms_variable_value'
    assert_select 'input[type=?]', 'submit'
  end

  def test_update
    var = cms_variables(:var001)
    @request.session[:user_id] = 1
    post :update, :id => var.id, :cms_variable => {:name => "new_name", :value => "new_value"}
    var.reload
    assert_equal "new_name", var.name
    assert_equal "new_value", var.value
  end

  def test_destroy
    @request.session[:user_id] = 1
    assert_difference "CmsVariable.count", -1 do
      delete :destroy, :id => cms_variables(:var001).id
    end
  end

  def test_create_without_permission
    @request.session[:user_id] = 2
    assert_no_difference 'CmsVariable.count' do 
      post :create,
        :cms_variable => {
          :name => "new_var",
          :value => "value for var"
        }
    end   
  end

  def test_destroy_without_permission
    @request.session[:user_id] = 2
    assert_no_difference "CmsVariable.count" do
      delete :destroy, :id => cms_variables(:var001).id
    end
  end

  def test_update_without_permission
    var = cms_variables(:var001)
    @request.session[:user_id] = 2
    post :update, :id => var.id, :cms_variable => {:name => "new_name", :value => "new_value"}
    var.reload
    assert_not_equal "new_name", var.name
    assert_not_equal "new_value", var.value
  end
end