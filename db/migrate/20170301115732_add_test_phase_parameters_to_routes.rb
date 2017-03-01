class AddTestPhaseParametersToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :protocol_test, :integer
    add_column :routes, :hostname_test, :string
    add_column :routes, :port_test, :string

    reversible do |direction|
      direction.up {
        Route.all.each do |route|
          route.protocol_test = route.protocol
          route.hostname_test = route.hostname
          route.port_test = route.port
          unless route.valid?
            pp route.inspect
            pp route.errors.messages
          end
          route.save!
        end
      }
    end
  end
end
