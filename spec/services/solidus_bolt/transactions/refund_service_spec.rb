# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusBolt::Transactions::RefundService, :vcr, :bolt_configuration do
  subject(:api) do
    described_class.new(
      transaction_reference: reference, amount: amount, currency: currency, payment_method: payment_method
    )
  end

  let(:transaction) do
    SolidusBolt::Transactions::AuthorizeService.call(
      order: order, credit_card: credit_card_payload, create_bolt_account: false, payment_method: payment_method
    )
  end
  let(:credit_card_payload) do
    tokenize_credit_card(credit_card_number: '4111111111111004', cvv: '111').merge(
      expiration: (Time.current + 1.year).strftime('%Y-%m'),
      token_type: 'bolt'
    )
  end
  let(:order) { create(:order_with_line_items) }
  let(:reference) { transaction['transaction']['reference'] }
  let(:amount) { transaction['transaction']['amount']['amount'] }
  let(:currency) { 'USD' }
  let(:payment_method) { create(:bolt_payment_method) }

  describe '#call', vcr: true do
    before do
      SolidusBolt::Transactions::CaptureService.call(
        transaction_reference: reference, amount: amount, currency: currency, payment_method: payment_method
      )
    end

    it 'makes the API call' do
      response = api.call

      expect(response['credit']['status']).to eq 'succeeded'
    end
  end
end
