module CmsHelper
  def cms_change_status_link(obj_name, obj)
    return unless obj.respond_to?(:status_id)
    url = {:controller => "#{obj_name}s", :action => 'update', :id => obj, obj_name.to_sym => params[obj_name.to_sym], :status => params[:status], :tab => nil}

    if obj.active?
      link_to l(:button_lock), url.merge(obj_name.to_sym => {:status_id => RedmineCms::STATUS_LOCKED}, :unlock => true), :method => :put, :remote => :true, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(obj_name.to_sym => {:status_id => RedmineCms::STATUS_ACTIVE}, :unlock => true), :method => :put, :remote => :true, :class => 'icon icon-unlock'
    end
  end

  def cms_visibilities_for_select(selected = nil, options={})
    grouped_options = {}
    grouped_options[l(:label_user_plural)] = [[l(:field_admin), '']] if options[:admin]
    grouped_options[l(:label_role_plural)] = [["Public", 'public'], ["Logged", 'logged']] unless options[:only_groups]
    grouped_options[l(:label_group_plural)] = Group.where(:type => 'Group').map{|g| [g.name, g.id]}
    grouped_options_for_select(grouped_options, selected)
  end

  def cms_reorder_links(name, url, method = :post)
    link_to(image_tag('2uparrow.png', :alt => l(:label_sort_highest)),
            url.merge({"#{name}[move_to]" => 'highest'}),
            :remote => true,
            :method => method, :title => l(:label_sort_highest)) +
    link_to(image_tag('1uparrow.png',   :alt => l(:label_sort_higher)),
            url.merge({"#{name}[move_to]" => 'higher'}),
            :remote => true,
            :method => method, :title => l(:label_sort_higher)) +
    link_to(image_tag('1downarrow.png', :alt => l(:label_sort_lower)),
            url.merge({"#{name}[move_to]" => 'lower'}),
            :remote => true,
            :method => method, :title => l(:label_sort_lower)) +
    link_to(image_tag('2downarrow.png', :alt => l(:label_sort_lowest)),
            url.merge({"#{name}[move_to]" => 'lowest'}),
            :remote => true,
            :method => method, :title => l(:label_sort_lowest))
  end

  def code_mirror_tags
    s = ''
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/lib/codemirror')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/lib/emmet')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/mode/overlay')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/search/search')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/search/searchcursor')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/dialog/dialog')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/htmlmixed/htmlmixed')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/css/css')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/xml/xml')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/javascript/javascript')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/textile/textile')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/keymap/sublime')
    s << stylesheet_link_tag('/plugin_assets/redmine_cms/codemirror/lib/codemirror')
    s << stylesheet_link_tag('/plugin_assets/redmine_cms/codemirror/theme/ambiance')
    s.html_safe
  end

  def link_to_cms_attachments(container, options = {})
    options.assert_valid_keys(:author, :thumbnails)

    attachments = container.attachments.preload(:author).to_a
    if attachments.any?
      options = {
        :editable => RedmineCms.allow_edit?,
        :deletable => RedmineCms.allow_edit?,
        :author => true
      }.merge(options)
      render :partial => 'attachments/links',
        :locals => {
          :container => container,
          :attachments => attachments,
          :options => options,
          :thumbnails => (options[:thumbnails] && Setting.thumbnails_enabled?)
        }
    end
  end
end