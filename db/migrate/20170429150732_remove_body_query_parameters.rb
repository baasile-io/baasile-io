class RemoveBodyQueryParameters < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up {
        QueryParameter.where(query_parameter_type: 2).destroy_all
      }
    end
  end
end
