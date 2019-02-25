require_relative "base"

module Toolbox::Auditors
  class Trading < Base

    include Toolbox::Helpers::Configuration

    def run!
      configure
      @statistics_mutex      = Mutex.new
      @created_orders_number = 0
      @times_min, @times_max, @times_count, @times_total = nil, nil, 0, 0.0

      Kernel.puts '' # Add a little padding.
      print_options
      Kernel.puts ''
    end

    protected
    def print_options
      options = {
        'Root URL' => @root_url.to_s,
        'Currencies' => @currencies.map(&:upcase).join(', '),
        'Markets' => @markets.map(&:upcase).join(', '),
        'Number of simultaneous traders' =>  @traders_number,
        'Number of orders to create' => @orders_number,
        'Number of simultaneous requests' => @threads_number,
        'Minimum order volume' => @min_volume,
        'Maximum order volume' => @max_volume,
        'Order volume step' => @volume_step,
        'Minimum order price' => @min_price,
        'Maximum order price' => @max_price,
        'Order price step' => @price_step,
      }
      length = options.keys.map(&:length).max
      options.each do |option, value|
        Kernel.puts "#{(option + ':').ljust(length + 1)} #{value}"
      end
    end

    def default_conf
      {
        threads:                         1,
        api_v2_jwt_algorithm:            'RS256',
        management_api_v2_jwt_signer:    'applogic',
        management_api_v2_jwt_algorithm: 'RS256',
        min_volume:                      1.0,
        max_volume:                      100.0,
        volume_step:                     1.0,
        min_price:                       0.5,
        max_price:                       1.5,
        price_step:                      0.1,
        report_yaml:                     "report-#{ Time.now.strftime("%F-%H%M%S") }.yml"
      }
    end

    def configure
      configure_root_url(@config.root_url)
      configure_currencies(@config.currencies)
      configure_markets(@config.markets)
      configure_traders_number(@config.traders)
      configure_orders_number(@config.orders)
      configure_threads_number(@config.threads)
      configure_volumes(@config.min_volume, @config.max_volume, @config.volume_step)
      configure_prices(@config.min_price, @config.max_price, @config.price_step)
      configure_api_v2(@config.api_v2_jwt_key, @config.api_v2_jwt_algorithm)
      configure_management_api_v2(@config.management_api_v2_jwt_key,
                                  @config.management_api_v2_jwt_signer,
                                  @config.management_api_v2_jwt_algorithm)
    end
  end
end
