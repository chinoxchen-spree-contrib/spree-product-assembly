module Spree
  module Admin
    module VariantsControllerDecorator
      def self.prepended(base)
        base.before_action :set_variants, only: %i[edit]
      end

      def set_variants
        @variants = []
        Spree::Product.can_be_parts.map{ |p| p.variants.map{ |v| @variants << [v.name, v.id]}}
      end
    end
  end
end

::Spree::Admin::VariantsController.prepend Spree::Admin::VariantsControllerDecorator
