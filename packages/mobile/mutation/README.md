# Mutation testing

Changes the domain code one small edit at a time (a `<` becomes `<=`, a `+`
becomes `-`) and runs that area's tests. A change the tests don't catch is a
gap in them. The nightly workflow fails below an 80% catch rate.

```bash
cd packages/mobile
flutter test --coverage   # lines no test reaches are skipped
dart run mutation_test mutation/*.xml -c coverage/lcov.info -o build/mutation -f html
```

It edits the source files in place while it runs: don't build or edit the
app at the same time. Each file is restored when its run ends.
