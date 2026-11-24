# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe 'QueryPreProcessor' do

  # TODO: write this spec - tests here are from previous home in tokeniser
  context 'with multiple unquoted terms' do
    context 'adjacent unquoted terms' do
      let!(:query) { "cats dogs" }
      it 'combines adjacent unquoted terms into an unquoted phrase' do
        expect(tokeniser.tokenise).to eq([[:unquoted_word, "cats dogs"]])
      end
    end

    context 'with a mix of unquoted terms and other term types' do
      let!(:query) { "cats dogs subject:rats pigeons birds" }
      it 'combines adjacent unquoted terms into multiple unquoted phrases' do
        expect(tokeniser.tokenise).to eq([[:unquoted_word, "cats dogs"], [:specified_field, "subject:rats"], [:unquoted_word, "pigeons birds"]])
      end
    end

    context 'where explicit boolean operators are included' do
      let!(:query) { "cats OR dogs AND subject:rats OR pigeons birds" }
      it 'does not combine unquoted terms separated by operators' do
        expect(tokeniser.tokenise).to eq([[:unquoted_word, "cats"], [:boolean_operator, "OR"], [:unquoted_word, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons birds"]])
      end
    end

    context 'where the "-" modifier operator is used' do
      let!(:query) { "-cats dogs AND subject:rats OR pigeons -birds" }
      it 'does not combine unquoted terms where one is modified by an operator that does not modify the other' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "-"], [:unquoted_word, "cats"], [:unquoted_word, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:modifier_operator, "-"], [:unquoted_word, "birds"]])
      end
    end

    context 'where the "+" modifier operator is used' do
      let!(:query) { "+cats dogs AND subject:rats OR pigeons +birds" }
      it 'does not combine unquoted terms where one is modified by an operator that does not modify the other' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "+"], [:unquoted_word, "cats"], [:unquoted_word, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:modifier_operator, "+"], [:unquoted_word, "birds"]])
      end
    end

    context 'where the NOT operator is used' do
      let!(:query) { "NOT cats dogs AND subject:rats OR pigeons NOT birds" }
      it 'behaves in the same manner as with the - form' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "NOT"], [:unquoted_word, "cats"], [:unquoted_word, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:modifier_operator, "NOT"], [:unquoted_word, "birds"]])
      end
    end

    context 'where the NOT operator is used with the optional AND operator' do
      let!(:query) { "NOT cats dogs AND subject:rats OR pigeons AND NOT birds" }
      it 'includes the AND operator' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "NOT"], [:unquoted_word, "cats"], [:unquoted_word, "dogs"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:boolean_operator, "AND"], [:modifier_operator, "NOT"], [:unquoted_word, "birds"]])
      end
    end

    context 'where brackets are used in combination with a NOT operator' do
      let!(:query) { "NOT (cats dogs) AND subject:rats OR pigeons AND NOT birds" }
      it 'takes the brackets into account' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "NOT"], [:parenthesis, "("], [:unquoted_word, "cats dogs"], [:parenthesis, ")"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:boolean_operator, "AND"], [:modifier_operator, "NOT"], [:unquoted_word, "birds"]])
      end
    end

    context 'where brackets are used in combination with the "-" operator' do
      let!(:query) { "-(cats dogs) AND subject:rats OR pigeons AND NOT birds" }
      it 'takes the brackets into account' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "-"], [:parenthesis, "("], [:unquoted_word, "cats dogs"], [:parenthesis, ")"], [:boolean_operator, "AND"], [:specified_field, "subject:rats"], [:boolean_operator, "OR"], [:unquoted_word, "pigeons"], [:boolean_operator, "AND"], [:modifier_operator, "NOT"], [:unquoted_word, "birds"]])
      end
    end

    context 'where the "-" operator is used with two consecutive terms' do
      let!(:query) { "-cats - dogs" }
      it 'takes the brackets into account' do
        expect(tokeniser.tokenise).to eq([[:modifier_operator, "-"], [:unquoted_word, "cats"], [:modifier_operator, "-"], [:unquoted_word, "dogs"]])
      end
    end

    xcontext 'where there are unbalanced brackets' do
      let!(:query) { "((cats dogs)" }
      it 'raises an error' do
        expect { tokeniser.tokenise }.to raise_error(Exception)
      end
    end

  end
end