class AddTestPhaseProxyParamaterToProxies < ActiveRecord::Migration[5.0]
  def change
    add_column      :proxies, :proxy_parameter_test_id, :integer, null: true

    reversible do |direction|
      direction.up {
        Proxy.all.each do |proxy|
          proxy.proxy_parameter_test = proxy.proxy_parameter.dup
          proxy.proxy_parameter_test.identifier = proxy.proxy_parameter.identifier.dup unless proxy.proxy_parameter.identifier.nil?
          proxy.save!
        end
      }
    end
  end
end
