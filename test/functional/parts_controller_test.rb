require File.expand_path('../../test_helper', __FILE__)

class PartsControllerTest < ActionController::TestCase
  fixtures :users, :pages, :parts, :pages_parts

  RedmineCMS::TestCase.create_fixtures([:pages, :parts, :pages_parts])

  def setup
    @controller = PartsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_new_part
    @request.session[:user_id] = 1
    get :new
    assert_response :success
    assert_select 'form#part-form'
    assert_select 'input#part_name', 1
    assert_select 'select#part_part_type', 1
    assert_select 'select#part_content_type', 1
    assert_select 'input#part_is_cached', 1
    assert_select 'textarea#part_content', 1
  end

  def test_create_part
    @request.session[:user_id] = 1
    assert_difference "Part.count", 1 do 
      post :create, :part =>{
        :name => "new_part",
        :part_type => "header",
        :content_type => "html",
        :is_cached => 1,
        :content => "<strong>Header content</content>"
      }
    end
    assert_redirected_to :controller => "parts", :action => 'edit', 
      :id => Part.find_by_name("new_part")
  end
    
  def test_create_part_without_privileges
    @request.session[:user_id] = 2
    assert_no_difference 'Part.count' do
      post :create, :part => {
        :name => "new_part",
        :part_type => "header",
        :content_type => "html",
        :is_cached => 1,
        :content => "<strong>Header content</content>"
      }
    end
    assert_response :forbidden
  end

  def test_not_find_part
    @request.session[:user_id] = 1
    get :show, :id => "not_exist_page"
    assert_response :missing
  end

  def test_update_part
    @request.session[:user_id] = 1
    part = Part.find(1)
    new_name = "updated_name"
    new_part_type = "textile"
    new_content = "New content"
    put :update, :id => part, :part => {
      :name => new_name,
      :part_type => new_part_type,
      :content => new_content
    }
    part.reload
    assert_equal new_name, part.name
    assert_equal new_part_type, part.part_type
    assert_equal new_content, part.content
  end

  def test_fail_update_part
    @request.session[:user_id] = 1
    part = Part.find(1)
    new_name = "updated name"
    new_part_type = "textile"
    new_content = "New content"
    put :update, :id => part, :part => {
      :name => new_name,
      :part_type => new_part_type,
      :content => new_content
    }
    assert_template :edit
  end

  def test_remove_part
    @request.session[:user_id] = 1
    assert_difference 'Part.count', -1 do
      post :destroy, :id => parts(:part_001)
    end
    assert_redirected_to :controller => 'pages', :action => 'index', :tab => "parts"
  end

  def test_index_parts
    @request.session[:user_id] = 1
    get :index
    assert_redirected_to :controller => 'pages', :action => 'index', :tab => "parts"
  end
end
