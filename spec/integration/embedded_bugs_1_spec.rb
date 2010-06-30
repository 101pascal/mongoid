require "spec_helper"

describe "Embedded Bugs Uno" do
  context "#<<" do
    before do
      Person.delete_all
      @person = Person.create
      @person.addresses << Address.new(:street => "Old Street")
      @person.addresses << Address.new(:street => "Hoxton Street")
      @person.save
    end

    it "thinks it added multiple items to an embedded collection" do
      @person.addresses.count.should eql 2
    end

    it "seems not to be the case as per the database" do
      @person.reload.addresses.count.should eql 2
    end
  end

  context "#=" do
    before do
      Person.delete_all
      @person = Person.create
      addresses = [Address.new(:street => "Old Street")]
      addresses << Address.new(:street => "Hoxton Street")
      @person.addresses = addresses
      @person.save
    end

    it "thinks it added multiple items to an embedded collection" do
      @person.addresses.count.should eql 2
    end

    it "seems not to be the case as per the database" do
      @person.reload.addresses.count.should eql 2
    end
  end
end
