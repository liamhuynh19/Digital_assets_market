require "rails_helper"
RSpec.describe Admin::ReportPolicy do
  let(:report) { double("Report") }
  context "for a seller" do
    let(:seller) do
      user = create(:user)
      user.add_role("seller")
      user.set_current_role("seller")
      user
    end

    let(:policy) { described_class.new(seller, report) }
    describe "show?" do
      it "permits access" do
        expect(policy.show?).to be true
      end
    end
  end
end
