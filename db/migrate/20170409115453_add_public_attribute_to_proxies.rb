class AddPublicAttributeToProxies < ActiveRecord::Migration[5.0]
  def change
    add_column :proxies, :public, :boolean, default: false

    reversible do |direction|
      direction.up {
        Proxy.update_all(public: true)
      }
    end
  end
end
