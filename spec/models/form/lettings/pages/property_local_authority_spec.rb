require "rails_helper"

RSpec.describe Form::Lettings::Pages::PropertyLocalAuthority, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { FormHandler.instance.forms["current_lettings"] }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true) }

  before do
    allow(form).to receive(:start_date).and_return(Time.utc(2022, 4, 1))
  end

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(
      %w[
        la
      ],
    )
  end

  it "has the correct id" do
    expect(page.id).to eq("property_local_authority")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "when routing to the page" do
    before do
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    context "when the log is general needs" do
      let(:log) { build(:lettings_log, needstype: 1) }

      it "is not routed to when `is_la_inferred` is nil" do
        log.is_la_inferred = nil
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when LA is inferred" do
        log.is_la_inferred = true
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is routed to when LA is not inferred" do
        log.is_la_inferred = false
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when the log is supported housing" do
      let(:log) { build(:lettings_log, needstype: 2) }

      it "is not routed to when `is_la_inferred` is nil" do
        log.is_la_inferred = nil
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to when LA is inferred" do
        log.is_la_inferred = true
        expect(page).not_to be_routed_to(log, nil)
      end

      it "is not routed to, even when LA is not inferred" do
        log.is_la_inferred = false
        expect(page).not_to be_routed_to(log, nil)
      end

      context "when the scheme has confidential information" do
        let(:log) { build(:lettings_log, needstype: 2, scheme: build(:scheme, sensitive: 1)) }

        it "is not routed to when `is_la_inferred` is nil" do
          log.is_la_inferred = nil
          expect(page).not_to be_routed_to(log, nil)
        end

        it "is not routed to when LA is inferred" do
          log.is_la_inferred = true
          expect(page).not_to be_routed_to(log, nil)
        end

        it "is not routed to, even when LA is not inferred" do
          log.is_la_inferred = false
          expect(page).not_to be_routed_to(log, nil)
        end
      end
    end
  end
end
