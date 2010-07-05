require "spec_helper"

describe "finicky call-backs in deeply-embedded relationships" do

  before(:each) do
    @foo = Foo.create(:name => "foo")
    @bar = @foo.bars.create(:name => "bar")
    # an aside : Would be consistent with the DSL to be able to do @bar.bazes.create...
    #
  end

  it "works" do
    @baz = @bar.bazes.create(:name => "baz")
    reload_baz
    @baz.populated_field.should_not be_nil
  end

  it "should work" do
    @bar.bazes << Baz.new(:name => "baz")
    @foo.save
    reload_baz
    @baz.populated_field.should_not be_nil
  end

  it "should work as well" do
    @bar.bazes = [Baz.new(:name => "baz")]
    @foo.save
    reload_baz
    @baz.populated_field.should_not be_nil
  end

  def reload_baz
    @baz = @foo.reload.bars.first.bazes.first
  end
end
