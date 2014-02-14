require 'spec_helper'

describe SpecialistDocumentRegistry do

  describe ".all" do
    before do
      irrelevant_artefact = FactoryGirl.create(:artefact, kind: 'publication', slug: 'government/whatever', owning_app: 'whitehall')
      FactoryGirl.create(:specialist_document_edition, panopticon_id: irrelevant_artefact.id)

      @edition_1, @edition_2 = [2, 1].map do |days_ago|
        artefact = FactoryGirl.create(:specialist_document_artefact, updated_at: days_ago.days.ago)
        FactoryGirl.create(:specialist_document_edition, panopticon_id: artefact.id)
      end
    end

    it "returns documents for all relevant artefacts by date updated desc" do
      SpecialistDocumentRegistry.all.map(&:title).should == [@edition_2, @edition_1].map(&:title)
    end
  end

  describe ".fetch" do
    before do
      @artefact = FactoryGirl.create(:specialist_document_artefact)
      @edition_1, @edition_2, @edition_3 = 1.upto(3).map do |i|
        FactoryGirl.create(:specialist_document_edition, panopticon_id: @artefact.id, version_number: i)
      end
    end

    it "loads the latest edition by default" do
      SpecialistDocumentRegistry.fetch(@artefact.id).title.should == @edition_3.title
    end

    it "loads a particular edition if version is specified" do
      SpecialistDocumentRegistry.fetch(@artefact.id, version_number: 2).title.should == @edition_2.title
    end
  end

  context "when the document doesn't exist" do
    before do
      @document = SpecialistDocument.new(title: "Example document about oil reserves")
      stub_out_panopticon
    end

    describe ".store!(document)" do
      it "creates an artefact and an edition at version 1" do
        SpecialistDocumentRegistry.store!(@document)

        artefact = Artefact.last
        editions = SpecialistDocumentEdition.where(panopticon_id: artefact.id)

        artefact.name.should == @document.title
        editions.count.should == 1
        editions.first.title.should == @document.title
        editions.first.version_number.should == 1
      end
    end

    describe ".publish!(document)" do
      it "raises an InvalidDocumentError" do
        expect { SpecialistDocumentRegistry.publish!(@document) }.to raise_error(SpecialistDocumentRegistry::InvalidDocumentError)
      end
    end
  end

  context "when the document exists in draft" do
    before do
      @document = SpecialistDocument.new(title: "Example document about oil reserves")
      artefact = FactoryGirl.create(:specialist_document_artefact)
      @document.id = artefact.id
      @draft_edition = FactoryGirl.create(:specialist_document_edition, panopticon_id: artefact.id, state: 'draft')
    end

    describe ".store!(document)" do
      it "updates the draft edition and keeps the same version number" do
        original_edition_version = @draft_edition.version_number

        SpecialistDocumentRegistry.store!(@document)
        @draft_edition.reload

        @draft_edition.title.should == @document.title
        @draft_edition.version_number.should == original_edition_version
      end
    end

    describe ".publish!(document)" do
      it "transitions the draft edition to published" do
        SpecialistDocumentRegistry.publish!(@document)
        @draft_edition.reload
        @draft_edition.state.should == 'published'
      end
    end
  end

  context "when the document exists and is published" do
    before do
      @document = SpecialistDocument.new(title: "Example document about oil reserves")
      artefact = FactoryGirl.create(:specialist_document_artefact, state: 'live')
      @document.id = artefact.id
      @published_edition = FactoryGirl.create(:specialist_document_edition, panopticon_id: artefact.id, state: 'published')
    end

    describe ".store!(document)" do
      it "creates a new edition in draft with an incremented version number" do
        original_edition_title = @published_edition.title
        original_edition_version = @published_edition.version_number

        SpecialistDocumentRegistry.store!(@document)

        editions = SpecialistDocumentEdition.where(panopticon_id: @document.id)
        editions.count.should == 2
        new_edition = editions.last

        @published_edition.reload

        @published_edition.title.should == original_edition_title
        @published_edition.version_number.should == original_edition_version

        new_edition.title.should == @document.title
        new_edition.version_number.should == @published_edition.version_number + 1
      end
    end

    describe ".publish!(document)" do
      it "does nothing" do
        SpecialistDocumentRegistry.publish!(@document)

        editions = SpecialistDocumentEdition.where(panopticon_id: @document.id)
        editions.count.should == 1
      end
    end
  end

end