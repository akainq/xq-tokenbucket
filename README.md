# tokenbucket

Token buckets for [XQ](https://akainq.github.io/xq/): a limit of a rate with bursts. A bucket holds up to `burst`
tokens and gets `rate` of them a second; a request takes one, or more, and is refused when there are not enough. A
bucket is a value: `take` gives the answer and the bucket after it, and nothing runs between requests — the tokens
come by the time that passed.

```bash
xq add tokenbucket
```

```ts
import * as tokenbucket from "tokenbucket";

function main(): void {
  // Two a second, five at once.
  const rule: tokenbucket.Rule = { rate: 2.0, burst: 5.0 };
  const now = performance.now();
  const [first, after] = tokenbucket.take(null, rule, now);
  const [all, _] = tokenbucket.take(after, rule, now, 5.0);
  console.log(`one: ${first}, five more at once: ${all}`);
}
```

## Functions

| Function | What it does |
|---|---|
| `Rule` | `{ rate: float; burst: float }`: `rate` tokens a second, `burst` at most |
| `Bucket` | `{ tokens: float; at: float }`: a bucket's tokens, and when it was last looked at, ms |
| `take(b: Bucket \| null, r: Rule, now: float, n: float = 1.0): [bool, Bucket]` | bucket `b` (`null`: a new one, full) asked for `n` tokens at `now`: whether it gave them, and the bucket after |
| `full(b: Bucket, r: Rule, now: float): bool` | whether a bucket is full again by `now`: it says nothing more than a new one, and may be forgotten |

Times are milliseconds of a clock that does not go back — `performance.now()`. A bucket may be set below zero — a
penalty: it gives nothing until it fills to a token again. Many buckets — of addresses, of users — are kept in a
`Map` by key in a process's state; dropping those `full` says are full keeps it small.

## Tests

```bash
xq test
```

## License

MIT OR Apache-2.0, at your option: [LICENSE-MIT](LICENSE-MIT), [LICENSE-APACHE](LICENSE-APACHE).
