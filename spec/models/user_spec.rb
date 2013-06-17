# coding: utf-8
require 'spec_helper'

describe User do
  describe "Check history" do
    context "name change" do
      before do
        @user = User.create!(:name => 'Makunouchi', :age => 22)
        @user.update_attributes!(:name => 'Sendo')
      end
      it "Get user history" do
        history = @user.model_history_records.last
        history.model_type.should == 'User'
        history.column_name.should == 'name'
        history.column_type.should == 'string'
        history.old_value.should == 'Makunouchi'
        history.new_value.should == 'Sendo'
      end
      it "#history_for_column" do
        histories = @user.history_for_column :name
        histories.should have(2).items
        histories.should == ['Makunouchi', 'Sendo']
      end
    end

    context "callback methods" do
      it "call add_model_history_record" do
        user = User.new(:name => "Makunouchi", :age => 22)
        user.should_receive(:set_model_history_changes)
        user.should_receive(:save_model_history)
        user.save!
      end
    end
  end
end
