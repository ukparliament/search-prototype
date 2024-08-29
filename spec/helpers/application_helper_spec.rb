require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe 'format_html' do
    context 'when not truncating html' do
      let!(:content) { "<div><strong>Hello world!</strong></div>" }
      it 'returns valid html' do
        expect(helper.format_html(content, 50)).to eq(content)
      end
    end
    context 'when truncating html' do
      let!(:content) { "<div><strong>Hello world!</strong></div>" }
      it 'returns valid html' do
        expect(helper.format_html(content, 1)).to eq("<div><strong>Hello...</strong></div>")
      end
    end
  end

  describe 'boolean_yes_no' do
    context 'when given nil' do
      it 'returns no' do
        expect(helper.boolean_yes_no(nil)).to eq('No')
      end
    end
    context 'when given a value of true' do
      let!(:data) { { value: true, field_name: 'field_name' } }
      it 'returns yes' do
        expect(helper.boolean_yes_no(data)).to eq('Yes')
      end
    end
    context 'when given a value of false' do
      let!(:data) { { value: false, field_name: 'field_name' } }
      it 'returns no' do
        expect(helper.boolean_yes_no(data)).to eq('No')
      end
    end
  end

  describe 'ordinal_text' do
    context 'when given 0' do
      it 'returns first' do
        expect(helper.ordinal_text(0)).to eq('first')
      end
    end
    context 'when given 1' do
      it 'returns second' do
        expect(helper.ordinal_text(1)).to eq('second')
      end
    end
    context 'when given 2' do
      it 'returns third' do
        expect(helper.ordinal_text(2)).to eq('third')
      end
    end
    context 'when given 3' do
      it 'returns fourth' do
        expect(helper.ordinal_text(3)).to eq('fourth')
      end
    end
    context 'when given 4' do
      it 'returns fifth' do
        expect(helper.ordinal_text(4)).to eq('fifth')
      end
    end
    context 'when given 5' do
      it 'returns sixth' do
        expect(helper.ordinal_text(5)).to eq('sixth')
      end
    end
    context 'when given 6' do
      it 'returns seventh' do
        expect(helper.ordinal_text(6)).to eq('seventh')
      end
    end
    context 'when given 7' do
      it 'returns eighth' do
        expect(helper.ordinal_text(7)).to eq('eighth')
      end
    end
    context 'when given 8' do
      it 'returns ninth' do
        expect(helper.ordinal_text(8)).to eq('ninth')
      end
    end
    context 'when given another number' do
      it 'returns a numeric ordinal string (zero indexed)' do
        expect(helper.ordinal_text(9)).to eq('10th')
      end
    end
  end

end