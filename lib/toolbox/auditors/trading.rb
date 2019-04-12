require_relative "base"

module Toolbox::Auditors
  class Trading < Base
    include Toolbox::Helpers::Configuration

    def run!
      configure

      @user_api_client = Toolbox::Clients::UserApiV2.new(@root_url, @api_v2_jwt_key, @api_v2_jwt_algorithm)
      @management_api_client = Toolbox::Clients::ManagementApiV2.new(@root_url, @management_api_v2_jwt_key,
                                                                     @management_api_v2_jwt_algorithm, @management_api_v2_jwt_signer)

      @orders_injector = "/toolbox/injectors/order/#{@orders.injector}"
                           .camelize
                           .constantize
                           .new(@orders.merge!(markets: @markets))
                           .tap(&:prepare!)

      Kernel.puts ''
      print_options
      Kernel.puts ''
      prepare_users
      Kernel.puts 'OK'
      @launched_at = Time.now
      create_and_run_workers
      @completed_at = Time.now
      report_to_file
    end

    protected

    # TODO: Add progress output.
    # E.g
    #   4 of 200 orders created (0.24 seconds passed).
    #   6 of 200 orders created (0.35 seconds passed).
    #   8 of 200 orders created (0.47 seconds passed).
    #   10 of 200 orders created (0.58 seconds passed).
    #   12 of 200 orders created (0.69 seconds passed).
    # TODO: Order creation failures processing.
    def create_and_run_workers
      Array.new(@threads_number) do
        Thread.new do
          loop do
            order = @orders_injector.pop
            break unless order
            @user_api_client.create_order(order, @users.sample)
          rescue => e
            Kernel.puts e.inspect
          end
        end
      end.each(&:join)
    end

    def report_to_file
      report_dir = File.join(TOOLBOX_ROOT, 'reports')
      report_file = File.join(report_dir, @config.report_yaml)

      Dir.mkdir report_dir unless Dir.exist? report_dir

      File.open(report_file, 'w') do |f|
        f.puts YAML.dump(compute_report)
      end
      puts "Report output to #{report_file_path}"
    end

    def compute_report
      ops = @orders.number / (@completed_at - @launched_at)

      @report = {
        'options' => {
          'root_url' => @root_url.to_s,
          'currencies' => @currencies.map(&:upcase),
          'markets' => @markets.map(&:upcase),
          'nb_concurent_traders' =>  @traders_number,
          'total_orders' => @orders.number,
          'nb_concurent_orders' => @threads_number,
          'orders' => @orders.to_h
        },
        'results' => {
          'ops' => ops,
          'time' => @completed_at - @launched_at
        }
      }
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
        'Order settings' => @orders.to_h,
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
        report_yaml:                     "#{auditor_name}-#{ Time.now.strftime("%F-%H%M%S") }.yml"
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
