class LayoutDrop < Liquid::Drop

  def url
    helpers.page_url(@page, :only_path => true)
  end

  def header_tags
    yield(:header_tags)
  end

  def header
    yield(:header)
  end

  def sidebar
    yield(:sidebar)
  end
  
  def footer
    yield(:footer)
  end  

  def content
    yield
  end

  def html_head_hook
    Redmine::Hook.call_hook(:view_layouts_base_html_head)
  end

  def body_bottom_hook
    Redmine::Hook.call_hook(:view_layouts_base_body_bottom)
  end

  private

  def app_helpers
    ApplicationController.helpers
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end    

end