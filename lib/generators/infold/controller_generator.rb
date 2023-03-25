require 'rails/generators/base'
require 'infold/writers/controller_writer'
require 'infold/resource'
require 'infold/db_schema'
require 'infold/yaml_reader'

module Infold
  class ControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def setup
      resource_name = name.camelize.singularize
      db_schema_file = Rails.root.join('db/schema.rb')
      db_schema = DbSchema.new(File.exist?(db_schema_file) ? File.read(db_schema_file) : nil)
      yaml = YAML.load_file(Rails.root.join("config/infold/#{resource_name.underscore}.yml"))
      resource = YamlReader.generate_resource(resource_name, yaml, db_schema)
      @writer = ControllerWriter.new(resource)
    end

    def create_controller_file
      template "controller.rb", Rails.root.join("app/controllers/admin/#{name.pluralize.underscore}_controller.rb"), force: true
    end

    def add_routes
      file = Rails.root.join('config/routes/admin.rb')
      route = "resources :#{name.pluralize.underscore}"
      return unless File.exist?(file)
      in_file = File.readlines(file).grep(/^\s+#{route}$/)
      if in_file.blank?
        inject_into_file file, after: "namespace 'admin' do" do
          "\n  #{route}"
        end
      end

      gsub_file file, "root :to => 'admin_users#index'",
                "root :to => '#{name.pluralize.underscore}#index'"
    end

    def add_menu
      return if name.pluralize.underscore == 'admin_users'
      file = Rails.root.join('app/views/admin/common/_header_menu.html.haml')
      return unless File.exist?(file)
      menu = "\n  %li.nav-item\n    = link_to Admin::#{@writer.resource_name(:model)}.model_name.human, #{@writer.index_path}, class: 'nav-link'"
      in_file = File.readlines(file).grep(/, #{@writer.index_path},/)
      if in_file.blank?
        append_to_file file do
          menu
        end
      end
    end
  end
end