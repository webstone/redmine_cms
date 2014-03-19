class LayoutDrop < Liquid::Drop
  include ActionView::Context
  include ActionView::Helpers::CaptureHelper


  def url
    helpers.page_url(@page, :only_path => true)
  end

  def header_tags
    content_for(:header_tags)
  end

  def header
    content_for(:header)
  end

  def sidebar
    content_for(:sidebar)
  end

  def footer
    _prepare_context
    content_for(:footer)
  end

  def content
    if block_given?
      yield
    else
      "no block"
    end
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