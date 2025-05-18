# Master Thesis Benchmark

Built on top of code from the [ClickBench](https://github.com/ClickHouse/ClickBench) project.

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
