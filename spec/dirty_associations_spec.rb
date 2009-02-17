require File.dirname(__FILE__) + '/spec_helper'

class MommyChicken < ActiveRecord::Base
  has_many :little_chickens
  dirty_associations :little_chickens
end
class LittleChicken < ActiveRecord::Base
end

describe MommyChicken do

  before do
    @mommy = MommyChicken.create(:name => "Gertrude")
    @little_chickens_was = []
  end

  it "new mommy should have little_chicken_changed? == false" do
    @mommy.little_chickens_changed?.should == false
  end

  it "little_chicken_was should return []" do
    @mommy.little_chickens_was.should == []
  end

  describe "adding a little chicken through .build" do
    
    before do
      @mommy.little_chickens.build(:name => "Junior")
    end

    it "little_chicken_changed? should be true before save" do
      @mommy.little_chickens_changed?.should == true
    end

    it "little_chicken_was should return proper value before save" do
      @mommy.little_chickens_was.should == @little_chickens_was
      @mommy.little_chickens_was.should_not == @mommy.little_chickens
    end

    it "little_chicken_changed? should be false after save" do
      @mommy.save
      @mommy.little_chickens_changed?.should == false
    end

    it "little_chicken_was should return proper value after save" do
      @mommy.save
      @mommy.little_chickens_was.should == @mommy.little_chickens
    end

  end

  describe "adding a little chicken through <<" do

    before do
      @mommy.little_chickens << LittleChicken.new(:name => "Junior")
    end

    it "little_chicken_changed? should be true before save" do
      @mommy.little_chickens_changed?.should == true
    end

    it "little_chicken_was should return proper value before save" do
      @mommy.little_chickens_was.should == @little_chickens_was
      @mommy.little_chickens_was.should_not == @mommy.little_chickens
    end

    it "little_chicken_changed? should be false after save" do
      @mommy.save
      @mommy.little_chickens_changed?.should == false
    end

    it "little_chicken_was should return proper value after save" do
      @mommy.save
      @mommy.little_chickens_was.should == @mommy.little_chickens
    end

  end

  describe "removing an existing little chicken" do

    before do
      @mommy.little_chickens.build(:name => "Junior")
      @mommy.little_chickens.build(:name => "Lewis")
      @mommy.save
      @little_chickens_was = @mommy.little_chickens.all
      @mommy.little_chickens_changed?.should == false
      @mommy.little_chickens.delete(@mommy.little_chickens.first)
    end

    it "little_chicken_changed? should be true before save" do
      @mommy.little_chickens_changed?.should == true
    end

    it "little_chicken_was should return proper value before save" do
      @mommy.little_chickens_was.should == @little_chickens_was
      @mommy.little_chickens_was.should_not == @mommy.little_chickens
    end

    it "little_chicken_changed? should be false after save" do
      @mommy.save
      @mommy.little_chickens_changed?.should == false
    end

    it "little_chicken_was should return proper value after save" do
      @mommy.save
      @mommy.little_chickens_was.should == @mommy.little_chickens
    end

  end

  describe "assigning other little chickens" do

    before do
      @mommy.little_chickens.build(:name => "Junior")
      @mommy.little_chickens.build(:name => "Lewis")
      @mommy.save
      @little_chickens_was = Array.new(@mommy.little_chickens)
      @mommy.little_chickens_changed?.should == false
      @mommy.little_chickens = [LittleChicken.find_by_name("Junior"), LittleChicken.new(:name => "Jimmy")]
    end

    it "little_chicken_changed? should be true before save" do
      @mommy.little_chickens_changed?.should == true
    end

    it "little_chicken_was should return proper value before save" do
      @mommy.little_chickens_was.should == @little_chickens_was
      @mommy.little_chickens_was.should_not == @mommy.little_chickens
    end

    it "mommy changed? should be true" do
      @mommy.changed?.should == true
    end

    it "mommy changed should be [\"little_chickens\"]" do
      @mommy.changed.should == ["little_chickens"]
    end

    it "mommy changes should return proper value" do
      @mommy.changes.should == {"little_chickens" => [@little_chickens_was, @mommy.little_chickens]}
    end

    it "mommy reload_with_dirty should not be changed?" do
      @mommy.reload_with_dirty.changed?.should == false
    end

    it "little_chicken_changed? should be false after save" do
      @mommy.save
      @mommy.little_chickens_changed?.should == false
    end

    it "little_chicken_was should return proper value after save" do
      @mommy.save
      @mommy.little_chickens_was.should == @mommy.little_chickens
    end

  end

end