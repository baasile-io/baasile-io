class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def is_destroyable?
    self.class.reflect_on_all_associations.all? do |assoc|
      ![:restrict_with_exception, :restrict_with_error].include?(assoc.options[:dependent]) ||
        (assoc.macro == :has_one && self.send(assoc.name).nil?) ||
        (assoc.macro == :has_many && self.send(assoc.name).empty?)
    end
  end

  def dependent_resources
    self.class.reflections.each_with_object([]) do |(assoc_name, assoc), list|
      if [:restrict_with_exception, :restrict_with_error].include?(assoc.options[:dependent])
        if (assoc.macro == :has_one && self.send(assoc.name).present?)
          list << self.send(assoc.name)
        elsif (assoc.macro == :has_many && self.send(assoc.name).any?)
          list.concat(self.send(assoc.name).to_a)
        end
      end
    end
  end
end
