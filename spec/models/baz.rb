class Baz
  include Mongoid::Document
  field :name
  field :populated_field
  embedded_in :bar, :inverse_of => :bazes
  before_save :call_back

  def call_back
    self.populated_field = "whatever"
  end
end
