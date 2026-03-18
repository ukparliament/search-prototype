# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FieldExpander' do
  let(:field_expander) { FieldExpander.new(field_name) }

  describe 'expand_fields' do
    context 'field name is title' do
      let(:field_name) { 'title' }
      it 'populates text_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: ["title_t"],
                                                    process_without_field: false })
      end
    end

    context 'field name is subject' do
      let(:field_name) { 'subject' }
      it 'populates text_fields and ses_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: ["subject_ses"],
                                                    ses_id_fields: [],
                                                    text_fields: ["subject_t"],
                                                    process_without_field: false })
      end
    end

    context 'field name is author' do
      let(:field_name) { 'author' }
      it 'populates text_fields and ses_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: ["creator_ses", "contributor_ses", "corporateAuthor_ses", "mep_ses", "section_ses", "tablingMember_ses", "askingMember_ses", "answeringMember_ses", "department_ses", "member_ses", "leadMember_ses", "correspondingMinister_ses"],
                                                    ses_id_fields: [],
                                                    text_fields: ["creator_t", "contributor_t", "corporateAuthor_t", "epCommittee_t", "department_t", "correspondingMinister_t"],
                                                    process_without_field: false })
      end
    end

    context 'field name is explanatorymemorandum' do
      let(:field_name) { 'explanatorymemorandum' }
      it 'populates boolean_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: ["containsEM_b"],
                                                    date_fields: [],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: [],
                                                    process_without_field: false })
      end
    end

    context 'field name is datecertified' do
      let(:field_name) { 'datecertified' }
      it 'populates date_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: ["dateCertified_dt", "certifiedDate_dt"],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: [],
                                                    process_without_field: false })
      end
    end

    context 'field name is date' do
      let(:field_name) { 'date' }
      it 'populates date_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: ["date_dt"],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: [],
                                                    process_without_field: false })
      end
    end

    context 'field name ends in _dt' do
      let(:field_name) { 'anything_dt' }
      it 'populates date_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: ["anything_dt"],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: [],
                                                    process_without_field: false })
      end
    end

    context 'field name ends in _ses' do
      let(:field_name) { 'anything_ses' }
      it 'populates ses_id_fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: [],
                                                    ses_id_fields: ["anything_ses"],
                                                    text_fields: [],
                                                    process_without_field: false })
      end
    end

    context 'field name is none' do
      let(:field_name) { 'none' }
      it 'sets process_without_field as true and populate and ses_fields with all_ses' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: ['all_ses'],
                                                    ses_id_fields: [],
                                                    text_fields: [],
                                                    process_without_field: true })
      end
    end
    context 'field name is other text' do
      let(:field_name) { 'unrecognised_field_name' }
      it 'populates text fields' do
        expect(field_expander.expand_fields).to eq(
                                                  { boolean_fields: [],
                                                    date_fields: [],
                                                    ses_fields: [],
                                                    ses_id_fields: [],
                                                    text_fields: ["unrecognised_field_name"],
                                                    process_without_field: false })
      end
    end
  end
end