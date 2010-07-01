require "spec_helper"

describe "Nested Attributes + Has Many" do

  before(:each) do
    Person.delete_all
    @person = Person.new
    @person.favorites.build(:title => "Ice Cream")
    @person.favorites.build(:title => "Jello")
    @person.save
  end

  shared_examples_for "a document with a destroyed embeds many" do    
    it "destroys when _destroy evaluates to true" do
      @person.save
      @person.reload.favorites.count.should eql 1
      @person.favorites.first.title.should == "Jello"
    end
  end

  context "_destroy => true" do
    before(:each) do
      @person.favorites_attributes = {
      "0" => { "_destroy" => true },
      "1" => { "_destroy" => false,
               "title"    => "Jello" }
      }
    end

    it_should_behave_like "a document with a destroyed embeds many"
  end

  context "_destroy => 1" do
    before(:each) do
      @person.favorites_attributes = {
      "0" => { "_destroy" => 1 },
      "1" => { "_destroy" => 0,
               "title"    => "Jello" }
      }
    end

    it_should_behave_like "a document with a destroyed embeds many"
  end

  context "_destroy => '1'" do
    before(:each) do
      @person.favorites_attributes = {
      "0" => { "_destroy" => '1' },
      "1" => { "_destroy" => '0',
               "title"    => "Jello" }
      }
    end

    it_should_behave_like "a document with a destroyed embeds many"
  end
end
