require 'redmine'

require 'uv'
require 'ultraviolet_syntax_patch'

Redmine::Plugin.register :redmine_ultraviolet do
  name "Redmine Ultraviolet Syntax highlighting plugin"
  author "Chris Gahan, Andy Bailey"
  description "Uses Textmate's syntaxes highlighters to highlight files in the source code repository."
  version "0.0.3"
  # Create a dropdown list in the UI so the admin can pick a theme.
  settings(:default => {
              'theme' => Uv::DEFAULT_THEME,
              'possible_values' => Uv::THEMES
             },
            :partial => 'ultraviolet_settings/redmine_ultraviolet_settings')
  
  # Hack into settings module to clear the textile cache after changing theme
  config.to_prepare do 
    Setting.class_eval do
      after_save :clear_textile_cache

      private
      def clear_textile_cache
        ActionController::Base.cache_store.delete_matched(/formatted_text/)
      end
    end
  end
end