class UpdateOldObjectsForNewVersion < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        Price.all do |price|
          if price.pricing_type.to_sym == :subscription && price.pricing_duration_type.to_sym == :prepaid
            puts price.id
            price.pricing_duration_type = :monthly
            price.save!
          end
        end
        Contract.where(status: :validation_production).each do |c|
          c.status = :waiting_for_production
          c.save
          puts c.price.inspect
          c.status = :validation_production
          c.save!
        end
      }
    end
  end
end
