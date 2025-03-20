require 'rails_helper'

RSpec.describe HierarchyHelper, type: :helper do
  describe 'collapse' do
    let!(:exp_types) { ["2", "3"] }

    context 'when tier is 1' do
      it 'returns an empty string' do
        expect(helper.collapse(1, exp_types, 1)).to eq('')
      end
    end
    context 'when tier is > 1' do
      context 'when id is not in expanded types' do
        it 'returns "collapse"' do
          expect(helper.collapse(2, exp_types, 1)).to eq('collapse')
        end
      end
      context 'when ID is in expanded types' do
        it 'returns an empty string' do
          expect(helper.collapse(2, exp_types, 2)).to eq('')
        end
      end
    end
  end

  describe 'has_children?' do
    let!(:hierarchy_data) { { 347260 => { :name => "Acts", :children => [{ :id => 352234, :name => "Private acts" }, { :id => 347135, :name => "Public acts" }] }, 352234 => { :name => "Private acts", :children => [] }, 347135 => { :name => "Public acts", :children => [] } } }

    context 'when the current layer has children' do
      context 'where the children are present in the results' do
        let!(:type_facets) { { 347260 => 1093, 352234 => 882, 347135 => 254 } }
        it 'returns true' do
          expect(helper.has_children?(hierarchy_data, 347260, type_facets)).to be true
        end
      end
      context 'where the children are not present in the results' do
        let!(:type_facets) { { 347260 => 1093 } }
        it 'returns false' do
          expect(helper.has_children?(hierarchy_data, 347260, type_facets)).to be false
        end
      end
    end
    context 'when the current layer has no children' do
      let!(:type_facets) { { 347260 => 1093, 352234 => 882, 347135 => 254 } }
      it 'returns false' do
        expect(helper.has_children?(hierarchy_data, 352234, type_facets)).to be false
      end
    end
  end

  describe 'toggle_symbol' do
    let!(:exp_types) { ["2", "3"] }

    context 'when ID is in expanded types' do
      it 'returns a minus sign' do
        expect(helper.toggle_symbol(exp_types, 3)).to eq('-')
      end
    end
    context 'when ID is not in expanded types' do
      it 'returns a plus sign' do
        expect(helper.toggle_symbol(exp_types, 1)).to eq('&#43;')
      end
    end
  end

  describe 'filter_applicable?' do
    let!(:test_params) { { "expanded_types" => ",347008", "filter" => { "type_sesrollup" => ["90996"] }, "query" => "brexit", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" } }

    context 'where ID is an applied filter' do
      it 'returns false' do
        expect(helper.filter_applicable?(test_params, 90996)).to be false
      end
    end
    context 'where ID is not an applied filter' do
      it 'returns true' do
        expect(helper.filter_applicable?(test_params, 347260)).to be true
      end
    end
  end

  describe 'name_and_count' do
    let!(:hierarchy_data) { { 347260 => { :name => "Acts", :children => [] } } }

    context 'where there is a count to display' do
      let!(:type_facets) { { 347260 => 1093 } }
      it 'returns the name and count for a given ID' do
        expect(helper.name_and_count(hierarchy_data, 347260, type_facets)).to eq('Acts (1,093)')
      end
    end
    context 'where there is not a count to display' do
      let!(:type_facets) { {} }
      it 'returns the name and a count of zero for a given ID' do
        expect(helper.name_and_count(hierarchy_data, 347260, type_facets)).to eq('Acts (0)')
      end
    end
  end
end