class Foo
  include Mongoid::Document
  field :name
  embeds_many :bars
end
