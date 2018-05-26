# RubyKube Toolbox

## Stress testing Peatio trading engine

See help pages:

* `docker run -it --rm rubykube/toolbox bin/stress_trading help`.

* `docker run -it --rm rubykube/toolbox bin/stress_trading help run`.

Usage example:
```sh
docker run -it --rm rubykube/toolbox bin/stress_trading --root-url http://peatio.trade --api-v2-jwt-key KEY --management-api-v1-jwt-key KEY --currencies uah,usd,eur --markets uahusd,uaheur --orders 1000 --traders 10 --threads 10 --report-yaml results.yml
```

The command above creates 10 traders each with 1 billion UAH, USD & USD. Then it opens 1000 new orders in UAHUSD, UAHEUR markets using 10 threads (parallel).
