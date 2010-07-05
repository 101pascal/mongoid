class Bar
  include Mongoid::Document
  field :name
  embeds_many :bazes, :class_name => "Baz"
  embedded_in :foo, :inverse_of => :bars
end
