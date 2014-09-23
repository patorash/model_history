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
        expect(history.model_type).to eq 'User'
        expect(history.column_name).to eq 'name'
        expect(history.column_type).to eq 'string'
        expect(history.old_value).to eq 'Makunouchi'
        expect(history.new_value).to eq 'Sendo'
      end
      it "#history_for_column" do
        histories = @user.history_for_column :name
        expect(histories.count).to eq 2
        expect(histories).to eq ['Makunouchi', 'Sendo']
      end
    end

    context 'multi columns change' do
      before do
        @user = User.create!(:name => 'Makunouchi', :age => 22)
        @user.update_attributes!(:name => 'Sendo', :age => 23)
      end
      it 'Get user histories' do
        histories = ModelHistoryRecord.created_at_gte(@user.updated_at)
        expect(histories.count).to eq 2
        histories.each do |history|
          if history.column_name == 'name'
            expect(history.old_value).to eq 'Makunouchi'
            expect(history.new_value).to eq 'Sendo'
          elsif history.column_name == 'age'
            expect(history.old_value).to eq 22
            expect(history.new_value).to eq 23
          end
        end
      end
    end

    context "callback methods" do
      it "call add_model_history_record" do
        user = User.new(:name => "Makunouchi", :age => 22)
        expect(user).to receive(:set_model_history_changes)
        expect(user).to receive(:save_model_history)
        user.save!
      end
    end
  end
end
