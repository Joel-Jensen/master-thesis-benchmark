# Master Thesis Benchmark

Built on top of code from the [ClickBench](https://github.com/ClickHouse/ClickBench) project.

## Download the data
1M: https://inly-master-thesis.ams3.digitaloceanspaces.com/transactions_1M.csv.gz

10M: https://inly-master-thesis.ams3.digitaloceanspaces.com/transactions_10M.csv.gz

wget <url>

gzip -d <file>

## Run the benchmark

Start by installting necessary programs
```bash
./install.sh
```

Init a strategy, where strategies can be `index | partition`
```bash
./setup.sh <strategy>
```

This will run the benchmark too. If you want to just rerun the bencharm you may with

```bash
./benchmark.sh
```

You can pass `-d` to debug and print out all the called lines. 

### pg_mooncake
To run the tests with pg_mooncake, look at the latest installation instructions here: https://pgmooncake.com/docs/installation