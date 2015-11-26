require File.expand_path('../../test_helper', __FILE__)

class CmsSettingsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :pages, :parts, :pages_parts

  RedmineCMS::TestCase.create_fixtures([:pages, :parts, :pages_parts])


  def test_save_settings_for_project
    @request.session[:user_id] = 1
    project = Project.find(1)
    post :save, :project_id => project.id,:cms_settings => {
      :landing_page => "Landing_page", 
      :project_tab_show_activity => 1,
      :project_tab_1_caption => "Caption for first page", 
      :project_tab_1_page => pages(:page_001).name
    }
    assert_equal "Caption for first page", RedmineCms.get_project_settings("project_tab_1_caption", project.id)
    assert_equal pages(:page_001).name, RedmineCms.get_project_settings("project_tab_1_page", project.id)
  end
end