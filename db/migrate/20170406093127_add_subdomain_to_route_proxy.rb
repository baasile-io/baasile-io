class AddSubdomainToRouteProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :subdomain, :string, default: nil
    add_column :proxies, :subdomain, :string, default: nil

    reversible do |direction|
      direction.up {
        Route.reset_column_information
        Proxy.reset_column_information
        Route.all.each do |r|
          temp = r.name.mb_chars.normalize(:kd).gsub(/[^\-A-Za-z0-9]/, '')
          temp += "--" if temp.length < 2
          temp = temp[0..31]
          r.update_attribute :subdomain, temp
        end

        Proxy.all.each do |p|
          temp = p.name.mb_chars.normalize(:kd).gsub(/[^\-A-Za-z0-9]/, '')
          temp += "--" if temp.length < 2
          temp = temp[0..31]
          p.update_attribute :subdomain, temp
        end
      }
    end
  end
end
