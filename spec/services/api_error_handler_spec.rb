require 'rails_helper'

RSpec.describe ApiErrorHandler do
  let!(:api_error_handler_instance) { ApiErrorHandler.new(response: mock_response) }
  
  context 'where solr returned an error' do
    context 'with a 500 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }

      it 'raises an ExternalServiceError' do
        expect { api_error_handler_instance.handle_errors }.to raise_exception ExternalServiceError
      end
    end
    context 'with a 401 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 401 } } }

      it 'raises an ExternalServiceError' do
        expect { api_error_handler_instance.handle_errors }.to raise_exception UnauthorizedError
      end
    end
    context 'with a 403 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 403 } } }

      it 'raises an ExternalServiceError' do
        expect { api_error_handler_instance.handle_errors }.to raise_exception UnauthorizedError
      end
    end
    context 'with a 404 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 404 } } }

      it 'raises an ExternalServiceError' do
        expect { api_error_handler_instance.handle_errors }.to raise_exception ObjectNotFoundError
      end
    end
  end
end