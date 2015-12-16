desc <<-END_DESC
Migrate CMS project settings from version 0.0.x to 1.x

Example:
  rake redmine:cms:migrate_settings RAILS_ENV="production"
END_DESC

namespace :redmine do
  namespace :cms do
    task :migrate_settings => :environment do
      old_settings = ContactsSetting.where("#{ContactsSetting.table_name}.name LIKE 'project_tab%' OR #{ContactsSetting.table_name}.name LIKE 'landing%'")

      old_settings.each do |old_setting|
        if RedmineCms.settings[:project][old_setting.project_id].blank?
          RedmineCms.settings[:project][old_setting.project_id] = {}
        end
        RedmineCms.settings[:project][old_setting.project_id][old_setting.name] = old_setting.value
      end
      RedmineCms.save_settings
      puts "#{old_settings.count} setting migrated"
    end
  end
end