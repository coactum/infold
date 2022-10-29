# require '/test/test_helper'
require 'infold/resource_config'
require 'infold/db_schema'
require 'hashie'

module Infold
  class ResourceConfigTest < ::ActiveSupport::TestCase
    test "model_associations should be return ModelAssociation" do
      setting = Hashie::Mash.new
      setting.model = { associations: { has_many: %w(one_details two_details),
                                        has_one: { three_detail: { option: 'Option' } },
                                        belongs_to: nil } }
      resource_config = ResourceConfig.new('product', setting)
      model_associations = resource_config.model_associations
      assert_equal(model_associations.size, 3)
      assert_equal(model_associations[0].kind, 'has_many')
      assert_equal(model_associations[0].field, 'one_details')
      assert_nil(  model_associations[0].options)
      assert_equal(model_associations[1].field, 'two_details')
      assert_equal(model_associations[2].kind, 'has_one')
      assert_equal(model_associations[2].field, 'three_detail')
      assert_equal(model_associations[2].options, { 'option' => 'Option' })
    end

    test "form_associations should be return FormAssociation" do
      setting = Hashie::Mash.new
      setting.model = { associations: { has_many: %w(one_details),
                                        has_one: %w(two_details) }}
      setting.app = { form: { fields: ['id', 'title', one_details: %w(name price)]} }
      resource_config = ResourceConfig.new('product', setting)
      form_associations = resource_config.form_associations
      assert_equal(form_associations.size, 1)
      assert_equal(form_associations[0].field, 'one_details')
    end

    test "active_storages should be return ActiveStorage (no thumb)" do
      setting = Hashie::Mash.new
      setting.model = { active_storage: %w(image pdf) }
      resource_config = ResourceConfig.new('product', setting)
      active_storages = resource_config.active_storages
      assert_equal(active_storages.size, 2)
      assert_equal(active_storages[0].field, 'image')
      assert_equal(active_storages[0].kind,  'file')
      assert_nil(active_storages[0].thumb)
    end

    test "active_storages should be return ActiveStorage with thumb" do
      setting = Hashie::Mash.new
      setting.model = { active_storage: { image: { kind: 'image', thumb: { kind: 'fill', width: 100, height: 200 } } } }
      resource_config = ResourceConfig.new('product', setting)
      active_storages = resource_config.active_storages
      assert_equal(active_storages.size, 1)
      assert_equal(active_storages[0].field, 'image')
      assert_equal(active_storages[0].kind,  'image')
      assert_equal(active_storages[0].thumb.to_h, { kind: 'fill', width: 100, height: 200 })
    end

  end
end