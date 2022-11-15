require 'test_helper'
require 'infold/writers/views/base_writer'
require 'infold/table'
require 'infold/field'
require 'infold/resource'

module Infold
  module Views
    class BaseWriterTest < ::ActiveSupport::TestCase
      test "if belongs_to field, field_display_code should be return link_to format" do
        field = Field.new('parent_id', :int)
        field.build_association(kind: :belongs_to,
                                association_table: Table.new('parents'),
                                name: 'parent',
                                name_field: 'address')
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        assert_equal("= link_to product.parent.address, admin_parent_path(product.parent), " +
                       "data: { turbo_frame: 'modal_sub' } if product.parent", code)
      end

      test "if image field, field_display_code should be return image format" do
        field = Field.new('photo')
        active_storage = field.build_active_storage(kind: :image)
        active_storage.build_thumb(kind: :fit, width: 100, height: 200)
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        expect_code = <<-HAML
- if product.photo.attached?
  = link_to url_for(product.photo), target: '_blank' do
    - if product.photo.blob.image?
      = image_tag(product.photo.variant(:thumb), class: 'img-fluid')
    - else
      = product.photo.filename
        HAML
        assert_match(expect_code, code.gsub('[TAB]', '  '))
      end

      test "if file field, field_display_code should be return file format" do
        field = Field.new('pdf')
        field.build_active_storage(kind: :file)
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        expect_code = <<-HAML
- if product.pdf.attached?
  = link_to product.pdf.filename, rails_blob_url(product.pdf), target: '_blank'
        HAML
        assert_match(expect_code, code.gsub('[TAB]', '  '))
      end

      test "if decorator field, field_display_code should be return decorator format" do
        field = Field.new('price', :integer)
        field.build_decorator(digit: true)
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        assert_equal("= product.price_display", code)
      end

      test "if colored enum field, field_display_code should be return enum badge format" do
        field = Field.new('status', :integer)
        enum = field.build_enum
        enum.add_elements(value: 1, color: 'red')
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        assert_equal("= render Admin::BadgeComponent.new(product.status_i18n, product.status_color)", code)
      end

      test "if enum field, field_display_code should be return enum format" do
        field = Field.new('status', :integer)
        field.build_enum
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        assert_equal("= product.status_i18n", code)
      end

      test "if colored enum field but for CSV, field_display_code should be return enum format" do
        field = Field.new('status', :integer)
        enum = field.build_enum
        enum.add_elements(value: 1, color: 'red')
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :csv)
        assert_equal("= product.status_i18n", code)
      end

      test "if string field, field_display_code should be return plain format" do
        field = Field.new('status', :integer)
        resource = Resource.new('Product', [])
        writer = BaseWriter.new(resource)
        code = writer.field_display_code(field, :list)
        assert_equal("= product.status", code)
      end
    end
  end
end