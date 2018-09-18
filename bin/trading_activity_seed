#!/usr/bin/env ruby

# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

def random_time_in_range(from, to)
  Time.at(random_in_range(from.to_time.to_i, to.to_time.to_i))
end

def random_in_range(from, to)
  rand(from..to)
end

def generate_order_randoms(order_settings)
  {
    volume:     random_in_range(order_settings[:min_volume], order_settings[:max_volume]),
    price:      random_in_range(order_settings[:min_price], order_settings[:max_price]),
    created_at: random_time_in_range(order_settings[:min_created_at], order_settings[:max_created_at]),
  }.yield_self { |o| o.merge updated_at: o[:created_at] }
end

def build_orders(market_id, orders_settings)
  orders  = []
  market  = Market.find_by_id(market_id)
  traders = Member.where(email: orders_settings[:traders].split(',').map(&:squish)).pluck(:id)
  orders_settings[:amount].times do
    orders << {
      ord_type:   :limit,
      bid:        market.quote_unit,
      ask:        market.base_unit,
      type:       orders_settings[:type] == 'bid' ? 'OrderBid' : 'OrderAsk',
      member_id:  traders.sample,
      market_id:  market.id,
      state:      ::Order::WAIT
    }.merge(generate_order_randoms(orders_settings))
  end
  orders
end

def update_dependant_trades_timestamp(orders_ids)
  Trade.where(ask_id: orders_ids) + Trade.where(bid_id: orders_ids).each do |trade|
    trade.created_at = trade.updated_at = [trade.bid.created_at,trade.ask.created_at].max
    trade.save!
  end
end

def trading_activity_seed
  orders_ids = []
  YAML.load_file(File.join(ENV.fetch('RAILS_ROOT'), 'config', 'trading_activity_seed.yml') || []).deep_symbolize_keys.each do |market, settings|
    settings.map do |orders_settings|
      orders_ids += build_orders(market, orders_settings)
                      .yield_self do |orders_array|
                        orders_array.map { |order_hash| Order.new(order_hash) }
                      end
                      .tap do |orders_objects|
                        Ordering.new(orders_objects).submit
                      end.map(&:id)
    end
  end

  # Wait additional time for orders matching and trades execution.
  sleep 2
  update_dependant_trades_timestamp(orders_ids)
end

trading_activity_seed
