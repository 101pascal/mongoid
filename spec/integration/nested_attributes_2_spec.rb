require "spec_helper"

describe "Nested Attributes + Has One" do

  before(:each) do
    Person.delete_all
    @person = Person.new
    @person.build_partner(:name => "Eva")
    @person.save
  end

  shared_examples_for "a document with a destroyed embeds one" do    
    it "destroys when _destroy evaluates to true" do
      @person.save
      @person.reload.partner.should be_nil
    end
  end

  context "_destroy => true" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => true }
    end

    it_should_behave_like "a document with a destroyed embeds one"
  end

  context "_destroy => 1" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => 1 }
    end

    it_should_behave_like "a document with a destroyed embeds one"
  end

  context "_destroy => '1'" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => "1" }
    end

    it_should_behave_like "a document with a destroyed embeds one"
  end

  shared_examples_for "a document with a not-destroyed embeds one" do    
    it "does not destroy when _destroy evaluates to false" do
      @person.save
      @person.reload.partner.should_not be_nil
    end
  end

  context "_destroy => false" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => false }
    end

    it_should_behave_like "a document with a not-destroyed embeds one"
  end

  context "_destroy => 0" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => 0 }
    end

    it_should_behave_like "a document with a not-destroyed embeds one"
  end

  context "_destroy => '0'" do
    before(:each) do
      @person.partner_attributes = { "_destroy" => "0" }
    end

    it_should_behave_like "a document with a not-destroyed embeds one"
  end
end
