#encoding: utf-8
class Paginate < Liquid::Block
  # example:
  #   {% paginate users.all by 5 %}{{ paginate | default_pagination }}{% endpaginate %}
  # paginate contacts by 20
  # paginate contacts by settings.pagination_limit
  Syntax = /(#{Liquid::VariableSignature}+)\s+by\s+(\d+|#{Liquid::VariableSignature}+)/

  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @collection_name = $1
      @size_or_variable = $2
    else
      raise Liquid::SyntaxError.new("Syntax Error in 'paginate' - Valid syntax: paginate [collection] by [size]")
    end
    super
  end

  def render(context)
    @size = ((@size_or_variable =~ /^\d+$/ && @size_or_variable) || context[@size_or_variable]).to_i
    collection = context[@collection_name] or return ''
    current_page = (context['current_page'] || 1).to_i
    items = collection.size
    pages = (items + @size -1) / @size
    in_page_collection = collection[(current_page-1)*@size, @size] or return ''
    collection.reject! {|item| !in_page_collection.include?(item)}

    context.stack do

      context['paginate'] = {
        'page_size'  => @size,
        'current_page'  => current_page,
        'current_offset'  => (current_page - 1) * @size,
        'pages'  => pages,
        'items'  => items,
      }
      if current_page > 1
        context['paginate']['previous'] = { 'url' => "?page=#{current_page - 1}", 'title' => 'Previous' }
      end
      query_param = context['q'] ? "&q=#{context['q']}" : ""
      context['paginate']['parts'] = (1..pages).map do |page|
        { 'url' => "?page=#{page}#{query_param}", 'title' => page, 'is_link' => (page != current_page) }
      end
      if current_page < pages
        context['paginate']['next'] = { 'url' => "?page=#{current_page + 1}#{query_param}", 'title' => 'Next' }
      end

      super
    end
  end

end

::Liquid::Template.register_tag('paginate', Paginate)