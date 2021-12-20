module Spree
  module Stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        if line_item.variant.reference_part_variant
          unless item_available?(line_item.order, line_item.variant.reference_part_variant, line_item.quantity)
            add_error(line_item, line_item.variant.reference_part_variant)
          end
        end

        line_item.quantity_by_variant.each do |variant, variant_quantity|
          unit_count = line_item.inventory_units.where(variant: variant).reject(&:pending?).sum(&:quantity)
          return false if unit_count >= line_item.quantity

          quantity = variant_quantity - unit_count
          return false if quantity.zero?

          next if item_available?(line_item.order, variant, quantity)
          add_error(line_item, variant)
        end

         line_item.errors.count.zero?
      end

      def add_error(line_item, variant)
        display_name = %Q{#{variant.name}}
        display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

        line_item.errors[:quantity] << Spree.t(
         :selected_quantity_not_available,
         item: display_name.inspect
        )
      end

      private

      def item_available?(order, variant, quantity)
        order.stock_locations.each do |stock_location|
          return true if Spree::Stock::Quantifier.new(variant.reference_part_variant || variant, stock_location).can_supply?(quantity)
        end
        false
      end
    end
  end
end
