class Partner
  include Mongoid::Document
  field :name
  embedded_in :person, :inverse_of => :partner
end
