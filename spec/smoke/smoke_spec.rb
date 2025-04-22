require 'rails_helper'

RSpec.describe 'Smoke Test', type: :request do
  it 'loads the home page successfully' do
    get root_path
    expect(response).to have_http_status(:ok)
  end

end


