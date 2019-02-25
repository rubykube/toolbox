require_relative "base"

module Toolbox::Auditors
  class Trading < Base
    include Toolbox::Helpers::Configuration

    def run!
      configure
      @statistics_mutex      = Mutex.new
      @created_orders_number = 0
      @times_min, @times_max, @times_count, @times_total = nil, nil, 0, 0.0
      @user_api_client = Toolbox::Clients::UserApiV2.new(@root_url, @api_v2_jwt_key, @api_v2_jwt_algorithm)
      @management_api_client = Toolbox::Clients::ManagementApiV2.new(@root_url, @management_api_v2_jwt_key,
                                                                     @management_api_v2_jwt_algorithm, @management_api_v2_jwt_signer)

      # TODO: Multiple market support.
      @orders_injector = "/toolbox/injectors/order/#{@orders.injector}"
                           .camelize
                           .constantize
                           .new(@orders.merge!(market: @markets.first))
                           .tap(&:prepare!)

      Kernel.puts ''
      print_options
      Kernel.puts ''
      prepare_users
      Kernel.puts 'OK'
      create_and_run_workers
    end

    protected

    def create_and_run_workers
      while order = @orders_injector.get_order
        @user_api_client.create_order(order.merge, @users.sample)
        puts order
      end
    end

    def prepare_users
      Kernel.print "Creating #{@traders_number} #{'user'.pluralize(@traders_number)}... "
      @users = @user_api_client.create_users(@traders_number)
      Kernel.puts 'Created'
      Kernel.print 'Making each user billionaire... '
      @users.each do |u|
        @currencies.each do |c|
          @management_api_client.create_deposit(uid: u[:uid], currency: c)
        end
      end
    end

    def print_options
      options = {
        'Root URL' => @root_url.to_s,
        'Currencies' => @currencies.map(&:upcase).join(', '),
        'Markets' => @markets.map(&:upcase).join(', '),
        'Number of simultaneous traders' =>  @traders_number,
        'Number of orders to create' => @orders_number,
        'Number of simultaneous requests' => @threads_number,
        'Order settings' => @orders,
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
        report_yaml:                     "report-#{ Time.now.strftime("%F-%H%M%S") }.yml"
      }
    end

    def configure
      configure_root_url(@config.root_url)
      configure_currencies(@config.currencies)
      configure_markets(@config.markets)
      configure_traders_number(@config.traders)
      configure_orders(@config.orders)
      configure_threads_number(@config.threads)
      configure_api_v2(@config.api_v2_jwt_key, @config.api_v2_jwt_algorithm)
      configure_management_api_v2(@config.management_api_v2_jwt_key,
                                  @config.management_api_v2_jwt_signer,
                                  @config.management_api_v2_jwt_algorithm)
    end
  end
end
