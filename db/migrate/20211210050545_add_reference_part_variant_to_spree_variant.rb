class AddReferencePartVariantToSpreeVariant < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_variants, :reference_part_variant, foreign_key: { to_table: :spree_variants }
  end
end
