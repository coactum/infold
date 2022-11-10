module Infold
  class FormElement
    include ActiveModel::Model

    attr_reader :field,
                :association_fields

    attr_accessor :association
    attr_writer :form_kind

    def initialize(field, **attrs)
      @field = field
      @association_fields = []
      super(**attrs)
    end

    def add_association_fields(field, **attrs)
      field.build_form_element(**attrs)
      @association_fields << field
    end

    def kind_association?
      field.association.present? || @form_kind.to_s == 'association'
    end

    def kind_file?
      field.active_storage.present? || @form_kind.to_s == 'file'
    end

    def kind_datetime?
      field.type.to_s == 'datetime'
    end

    def form_kind
      if kind_datetime?
        :datetime
      elsif kind_file?
        :file
      elsif kind_association?
        :association
      else
        (@form_kind.presence || :text).to_sym
      end
    end
  end
end