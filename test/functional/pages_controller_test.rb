require File.expand_path('../../test_helper', __FILE__)

class PagesControllerTest < ActionController::TestCase
  
  fixtures :users, :pages, :parts, :pages_parts, :cms_content_versions

  RedmineCMS::TestCase.create_fixtures([:pages, :parts, :pages_parts, :cms_content_versions])

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

  def test_not_find_page
    @request.session[:user_id] = 1
    get :show, :id => "not_exist_page"
    assert_response :missing
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

  def test_create_page
    @request.session[:user_id] = 1
    assert_difference 'Page.count' do
      post :create, :page => {
        :name => "New_page",
        :title => "title for page",
        :visibility => "public",
        :keywords => "some keywords",
        :content => "Content"
      }
    end
    assert_redirected_to :controller => "pages", :action => 'edit', :id => Page.last
  end

  def test_fail_create_page
    @request.session[:user_id] = 1
    assert_no_difference 'Page.count' do
      post :create, :page => {
        :name => "New page",
        :title => "title for page",
        :visibility => "public",
        :keywords => "some keywords",
        :content => "Content"
      }
    end
    assert_template :new
  end

  def test_create_page_without_privileges
    @request.session[:user_id] = 2
    assert_no_difference 'Page.count' do
      post :create, :page => {
        :name => "New_page",
        :title => "title for page",
        :visibility => "public",
        :keywords => "some keywords",
        :content => "Content"
      }
    end
    assert_response :forbidden
  end

  def test_index_page
    @request.session[:user_id] = 1
    get :index
    assert_select "a#tab-pages",1
    assert_select "a#tab-cms_menus",1
    assert_select "a#tab-parts",1
    assert_select "tr.page", Page.count do
      assert_select 'td.name', Page.count*2
      assert_select 'td.buttons', Page.count
    end
    assert_select 'a.icon-add[href=?]', "/pages/new"
    # parts
    assert_select "tr.part", Part.count do
      assert_select 'td.name', Part.count
      assert_select 'td.type', Part.count
      assert_select 'td.buttons', Part.count
    end
    assert_select 'a.icon-add[href=?]', "/parts/new"

  end

  def test_tab_for_part_of_page
    @request.session[:user_id] = 1
    get :edit, :id => pages(:page_001)
    assert_response :success
    assert_select 'a#tab-edit', 1
    assert_select 'a#tab-page_parts', 1
    assert_select 'form[action=?]', "/pages_parts?page_id=#{pages(:page_001)}"
    assert_select 'select#part_id' do
      assert_select 'optgroup option', {:count => 1, :text => parts(:part_001).to_s}
    end
    assert_select 'a[href=?]', "/parts/new"
    assert_select 'tr.part', pages(:page_001).parts.count
  end


  def test_update_page
    @request.session[:user_id] = 1
    page = Page.find(1)
    new_name = "updated_name"
    new_title = "changed title"
    new_status = 0
    new_content = "New content"
    put :update, :id => page, :page => {
      :name => new_name,
      :title => new_title,
      :status_id => new_status,
      :content => new_content
    }
    page.reload
    assert_equal new_name, page.name
    assert_equal new_title, page.title
    assert_equal new_status, page.status_id
    assert_equal new_content, page.content
  end
  
  def test_fail_update_page
    @request.session[:user_id] = 1
    page = Page.find(1)
    new_name = "updated name"
    new_title = "changed title"
    new_status = 0
    new_content = "New content"
    put :update, :id => page, :page => {
      :name => new_name,
      :title => new_title,
      :status_id => new_status,
      :content => new_content
    }
    assert_template :edit
  end

  def test_remove_page
    @request.session[:user_id] = 1
    assert_difference 'Page.count', -1 do
      post :destroy, :id => pages(:page_001)
    end
    assert_redirected_to :controller => 'pages', :action => 'index', :tab => "pages"
  end

  def test_history_page
    @request.session[:user_id] = 1
    page = pages(:page_001)
    get :history, :id => page
    assert_response :success
    assert_select 'table.wiki-page-versions'
    assert_select 'td.id a', {:href => page_url(page, :version => page.version)}
  end

  def test_version_diff
    @request.session[:user_id] = 1
    page1 = pages(:page_001)
    page1.content = "New content"
    page1.save
    get :diff, :id => page1,  :version => page1.version, :version_from => 1
    assert_response :success
    assert_select '.text-diff'
  end

  def test_show_page_with_specific_version
    @request.session[:user_id] = 1
    page1 = pages(:page_001)
    get :show, :id => page1, :version => 1
    assert_response :success
    assert_match page1.versions.where(:version => 1).first.content, @response.body
    assert_select 'a.icon', {:href => edit_page_url(page1, :version => 1)}
  end
end
