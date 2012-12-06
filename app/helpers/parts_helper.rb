module PartsHelper
  def change_part_status_link(part)
    url = {:controller => 'parts', :action => 'update', :id => part, :part => params[:part], :status => params[:status], :tab => nil}

    if part.active?
      link_to l(:button_lock), url.merge(:part => {:status_id => Page::STATUS_LOCKED}), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:part => {:status_id => Page::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
    end
  end  
end
