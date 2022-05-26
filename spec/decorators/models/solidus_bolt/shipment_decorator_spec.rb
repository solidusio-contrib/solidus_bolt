require 'spec_helper'

RSpec.describe SolidusBolt::ShipmentDecorator do
  let(:payment_method) { create(:bolt_payment_method) }
  let(:payment_source) { create(:bolt_payment_source) }
  let(:payment) do
    create(
      :payment,
      state: 'completed',
      source_id: payment_source.id,
      source_type: SolidusBolt::PaymentSource,
      payment_method_id: payment_method.id,
      response_code: 'Doctor Strange'
    )
  end
  let(:order) { payment.order }

  describe '#bolt_items' do
    it 'returns an array' do
      create(:shipment, order: order, id: rand(1..10), tracking: 'MockBolt1678')
      order.shipments.reload
      shipment = order.shipments.last
      items = shipment.bolt_items

      expect(items).to be_a(Array)
    end

    it 'lists all line_items' do
      create(:shipment, order: order, id: rand(1..10), tracking: 'MockBolt1678')
      order.shipments.reload
      shipment = order.shipments.last
      items = shipment.bolt_items

      expect(items.count).to eq(order.line_items.count)
    end
  end
end
