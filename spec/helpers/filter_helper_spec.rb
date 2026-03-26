require 'rails_helper'

RSpec.describe FilterHelper, type: :helper do
  describe 'remove_filter_url' do
    let(:params_hash) { HashWithIndifferentAccess.new({ "filter" => { "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }

    context 'for a month filter' do
      it 'clears month and year filtering, in addition to resetting to the first page' do
        expect(helper.remove_filter_url(params_hash, 'date_month', '3')).to eq("/search?filter%5Bdepartment_ses%5D%5B%5D=25060&filter%5Bdepartment_ses%5D%5B%5D=488564&query=refugees&results_per_page=20&show_detailed=&sort_by=date_desc")
      end
    end

    context 'for a year filter' do
      it 'clears month and year filtering, in addition to resetting to the first page' do
        expect(helper.remove_filter_url(params_hash, 'date_year', '2025')).to eq("/search?filter%5Bdepartment_ses%5D%5B%5D=25060&filter%5Bdepartment_ses%5D%5B%5D=488564&query=refugees&results_per_page=20&show_detailed=&sort_by=date_desc")
      end
    end

    context 'for any other filter' do
      it 'clears the filter specifically for that field and value, in addition to resetting to the first page' do
        expect(helper.remove_filter_url(params_hash, 'department_ses', '488564')).to eq("/search?filter%5Bdate_month%5D%5B%5D=3&filter%5Bdate_year%5D%5B%5D=2023&filter%5Bdepartment_ses%5D%5B%5D=25060&query=refugees&results_per_page=20&show_detailed=&sort_by=date_desc")
      end
    end
  end

  describe 'apply_filter_url' do
    let(:params_hash) { HashWithIndifferentAccess.new({ "filter" => { "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }

    context 'for any filter' do
      it 'adds the new filter and resets to the first page' do
        expect(helper.apply_filter_url(params_hash, 'department_ses', '488564')).to eq("/search?filter%5Bdate_month%5D%5B%5D=3&filter%5Bdate_year%5D%5B%5D=2023&filter%5Bdepartment_ses%5D%5B%5D=488564&filter%5Bdepartment_ses%5D%5B%5D=25060&query=refugees&results_per_page=20&show_detailed=&sort_by=date_desc")
      end
    end
  end

  describe 'visible_filters' do
    context 'a month filter has not been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }

      it 'shows all applied filters' do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.visible_filters).to eq(ActionController::Parameters.new({ "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }))
      end
    end

    context 'a month filter has been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }
      it 'does not show the year filter' do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.visible_filters).to eq(ActionController::Parameters.new({ "date_month" => ["3"], "department_ses" => ["25060", "488564"] }))
      end
    end
  end

  describe 'applied_filters' do
    context 'a month filter has not been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }

      it 'shows all applied filters' do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.applied_filters).to eq(ActionController::Parameters.new({ "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }))
      end
    end

    context 'a month filter has been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }
      it 'shows all applied filters' do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.applied_filters).to eq(ActionController::Parameters.new({ "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }))
      end
    end
  end

  describe 'current_month_filter_value' do
    context 'a month filter has not been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }

      it 'returns nil' do
        expect(helper.current_month_filter_value).to be_nil
      end
    end

    context 'a month filter has been applied' do
      let(:params) { ActionController::Parameters.new({ "filter" => { "date_month" => ["3"], "date_year" => ["2023"], "department_ses" => ["25060", "488564"] }, "page" => "3", "query" => "refugees", "results_per_page" => "20", "show_detailed" => "", "sort_by" => "date_desc", "controller" => "search", "action" => "index" }) }
      it 'returns the value for the month' do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.current_month_filter_value).to eq('3')
      end
    end
  end
end
