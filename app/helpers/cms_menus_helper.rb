module CmsMenusHelper

  def change_menu_status_link(cms_menu)
    url = {:controller => 'cms_menus', :action => 'update', :id => cms_menu, :cms_menu => params[:cms_menu], :status => params[:status], :tab => nil}

    if cms_menu.active?
      link_to l(:button_lock), url.merge(:cms_menu => {:status_id => RedmineCms::STATUS_LOCKED}), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:cms_menu => {:status_id => RedmineCms::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
    end
  end

end
