# require '/test/test_helper'
require 'infold/model_config'
require 'hashie'

module Infold
  class ModelConfigTest < ::ActiveSupport::TestCase
    test "model_associations should be return ModelAssociation" do
      setting = Hashie::Mash.new
      setting.model = { associations: { has_many: %w(one_details two_details),
                                        has_one: { three_detail: { option: 'Option' } },
                                        belongs_to: nil } }
      model_config = ModelConfig.new('product', setting)
      model_associations = model_config.model_associations
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
      model_config = ModelConfig.new('product', setting)
      form_associations = model_config.form_associations
      assert_equal(form_associations.size, 1)
      assert_equal(form_associations[0].field, 'one_details')
    end

    test "active_storages should be return ActiveStorage (no thumb)" do
      setting = Hashie::Mash.new
      setting.model = { active_storage: %w(image pdf) }
      model_config = ModelConfig.new('product', setting)
      active_storages = model_config.active_storages
      assert_equal(active_storages.size, 2)
      assert_equal(active_storages[0].field, 'image')
      assert_equal(active_storages[0].kind,  'file')
      assert_nil(active_storages[0].thumb)
    end

    test "active_storages should be return ActiveStorage with thumb" do
      setting = Hashie::Mash.new
      setting.model = { active_storage: { image: { kind: 'image', thumb: { kind: 'fill', width: 100, height: 200 } } } }
      model_config = ModelConfig.new('product', setting)
      active_storages = model_config.active_storages
      assert_equal(active_storages.size, 1)
      assert_equal(active_storages[0].field, 'image')
      assert_equal(active_storages[0].kind,  'image')
      assert_equal(active_storages[0].thumb.to_h, { kind: 'fill', width: 100, height: 200 })
    end

    test "validates should be return Validate" do
      setting = Hashie::Mash.new
      setting.model = { validates: {
        stock: 'presence',
        name: %w(presence unique),
        price: ['presence', { range: { floor: 0, ceil: 100 } }]
      }}
      model_config = ModelConfig.new('product', setting)
      validates = model_config.validates
      assert_equal(validates.size, 3)
      assert_equal(validates[0].field, 'stock')
      assert_equal(validates[0].conditions.size, 1)
      assert_equal(validates[0].conditions[0].to_h, { condition: 'presence', options: nil })
      assert_equal(validates[1].field, 'name')
      assert_equal(validates[1].conditions.size, 2)
      assert_equal(validates[1].conditions[1].to_h, { condition: 'unique', options: nil })
      assert_equal(validates[2].field, 'price')
      assert_equal(validates[2].conditions.size, 2)
      assert_equal(validates[2].conditions[0].to_h, { condition: 'presence', options: nil })
      assert_equal(validates[2].conditions[1].to_h, { condition: 'range', options: { 'floor' => 0, 'ceil' => 100 } })
    end

    test "enum should be return Enum (has no color)" do
      setting = Hashie::Mash.new
      setting.model = { enum: { status: {
        ordered: 1,
        charged: 2,
        delivered: 3
      } } }
      model_config = ModelConfig.new('product', setting)
      enum = model_config.enum
      assert_equal(enum.size, 1)
      assert_equal(enum[0].field, 'status')
      assert_equal(enum[0].elements.size, 3)
      assert_equal(enum[0].elements[0].key, 'ordered')
      assert_equal(enum[0].elements[0].value, 1)
    end

    test "enum should be return Enum (with color)" do
      setting = Hashie::Mash.new
      setting.model = { enum: {
        status: {
          ordered: { value: 1, color: 'red'  },
          charged: { value: 2, color: 'blue' }
        },
        category: {
          kitchen: 1,
          dining: 2
        }
      } }
      model_config = ModelConfig.new('product', setting)
      enum = model_config.enum
      assert_equal(enum.size, 2)
      assert_equal(enum[0].field, 'status')
      assert_equal(enum[0].elements.size, 2)
      assert_equal(enum[0].elements[0].key, 'ordered')
      assert_equal(enum[0].elements[0].value, 1)
      assert_equal(enum[0].elements[0].color, 'red')
      assert_equal(enum[0].elements[1].key, 'charged')
      assert_equal(enum[0].elements[1].value, 2)
      assert_equal(enum[0].elements[1].color, 'blue')
      assert_equal(enum[1].field, 'category')
      assert_equal(enum[1].elements[0].key, 'kitchen')
      assert_equal(enum[1].elements[0].value, 1)
      assert_nil(  enum[1].elements[0].color)
    end

    test "decorator should be return Decorator" do
      setting = Hashie::Mash.new
      setting.model = { decorates: {
        price: {
          append: "円",
          digit: true
        },
        phone: {
          prepend: "TEL:"
        }
      }}
      model_config = ModelConfig.new('product', setting)
      decorator = model_config.decorator
      assert_equal(decorator.size, 2)
      assert_equal(decorator[0].field, 'price')
      assert_equal(decorator[0].append, '円')
      assert_nil(decorator[0].prepend)
      assert(decorator[0].digit)
      assert_equal(decorator[1].field, 'phone')
      assert_equal(decorator[1].prepend, 'TEL:')
    end
  end
end