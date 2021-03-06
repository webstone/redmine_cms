require File.expand_path('../../test_helper', __FILE__)

class CmsRedirectTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_redmine_cms["redirects"] = []
    @redirect1 = CmsRedirect.new(
      :source_path => '/source_path',
      :destination_path => '/destination_path'
    )
    @redirect1.save

    @redirect2 = CmsRedirect.new(
      :source_path => '/source_path2',
      :destination_path => '/destination_path2'
    )
    @redirect2.save
  end

  def test_all
    result_all = CmsRedirect.all
    assert result_all.is_a?(Array), "Result of '.all' function is not a array"
    assert_equal result_all.count, Setting.plugin_redmine_cms["redirects"].size
    result_all.each do |rd|
      assert (rd.source_path == @redirect1.source_path) || (rd.source_path == @redirect2.source_path), "Did not find saved redirects in result (#{result_all.count})"
    end
  end

  def test_save
    old_count_of_redirect = Setting.plugin_redmine_cms["redirects"].size
    new_redirect = CmsRedirect.new(
      :source_path => "/new_source_path",
      :destination_path => "/new_destination_path"
    )
    new_redirect.save
    assert_equal old_count_of_redirect + 1, Setting.plugin_redmine_cms["redirects"].size
    assert_equal new_redirect.destination_path, Setting.plugin_redmine_cms["redirects"][new_redirect.source_path]
  end

  def test_destroy
    old_count_of_redirect = Setting.plugin_redmine_cms["redirects"].size
    rd = CmsRedirect.all.first
    assert rd.destroy, "Got false but expected true when destroy redirect"
    assert_equal old_count_of_redirect - 1,  Setting.plugin_redmine_cms["redirects"].size
  end

  def test_persisted
    assert !@redirect1.persisted?
  end

  def test_validate
    bad_paths = ["/admin", "/settings", "/users", "/groups", "/plugins", "/cms_redirects"]
    destination_path = "/some_dest_path"
    bad_paths.each do |path|
      new_redirect = CmsRedirect.new(
        :source_path => path,
        :destination_path => destination_path
      )
      assert !new_redirect.save, "Can save redirect with invalid source path (#{path})"
    end
  end

  def test_to_params
    assert_equal @redirect1.source_path.parameterize, @redirect1.to_param
    @redirect1.source_path = "/"
    assert_equal "_", @redirect1.to_param
  end
end

