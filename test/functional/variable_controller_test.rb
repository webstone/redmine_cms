require File.expand_path('../../test_helper', __FILE__)

class VariableControllerTest < ActionController::TestCase
  fixtures :variables

  # RedmineCMS::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_cms).directory + '/test/fixtures/', [:variables])
  RedmineCMS::TestCase.create_fixtures([:variables])
  def setup
    @controller = VariablesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_new
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select 'input#variable_name'
    assert_select 'input#variable_value'
    assert_select 'input[type=?]', 'submit'
  end

  def test_create
    @request.session[:user_id] = 1
    assert_difference 'Variable.count' do 
      post :create,
        :variable => {
          :name => "new_var",
          :value => "value for var"
        }
    end   
  end

  def test_edit
    @request.session[:user_id] = 1
    get :edit, :id => variables(:var001).id
    assert_response :success
    assert_select 'input#variable_name'
    assert_select 'input#variable_value'
    assert_select 'input[type=?]', 'submit'
  end

  def test_update
    var = variables(:var001)
    @request.session[:user_id] = 1
    post :update, :id => var.id, :variable => {:name => "new_name", :value => "new_value"}
    var.reload
    assert_equal "new_name", var.name
    assert_equal "new_value", var.value
  end

  def test_destroy
    @request.session[:user_id] = 1
    assert_difference "Variable.count", -1 do
      delete :destroy, :id => variables(:var001).id
    end
  end

  def test_permission
    @request.session[:user_id] = 2
    get :new
    assert_response 403
    get :edit, :id => variables(:var001).id
    assert_response 403
    post :update, :id => variables(:var001).id, :variable => {:name => "new_name", :value => "new_value"}
    assert_response 403
    delete :destroy, :id => variables(:var001).id
    assert_response 403
  end
end