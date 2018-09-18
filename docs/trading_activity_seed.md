## Trading Activity Seed

This script provides the easiest way to seed your platform with some trading activity.

### Running

1. Copy bin/trading_activity_seed.rb to YOUR-PEATIO-DIRECTORY/bin
You can use `cp` if you run peatio locally or `curl` if you use docker container

2. Copy config/trading_activity_seed.yml to YOUR-PEATIO-DIRECTORY/config
You can use `cp` if you run peatio locally or `curl` if you use docker container

3. Change seed file.

4. Make sure that your traders have enough funds for trading.
*Don't use it in production!* You can seed some fake balance using script bellow (run it from rails console).
```ruby
members    = 'admin@barong.io,admin@peatio.tech'.split(',').map(&:squish)
currencies = 'usd,btc,eth'.split(',').map(&:squish)
amount     = 50

Account.where(currency_id: currencies)\
       .joins(:member)\
       .merge(Member.where(email: members))\
       .find_each { |a| a.plus_funds!(amount) }
```

5. Run script `RAILS_ROOT=YOUR-PEATIO-DIRECTORY bundle exec ruby bin/trading_activity_seed.rb`

6. If you have some trading activity cached in Redis (k-daemon) you need to clean up it and k-daemon will regenerate it.
```bash
KLINE_DB="redis-cli -n 1"
KLINE_DB KEYS "peatio:*:k:*" | xargs $KLINE_DB DEL
```
