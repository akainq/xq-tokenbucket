// tokenbucket: token buckets for XQ — a limit of a rate with bursts. A bucket holds up to `burst` tokens
// and gets `rate` of them a second; a request takes one (or more), and is refused when there are not
// enough. A bucket is a value: `take` gives the answer and the bucket after, and nothing runs between
// requests — the tokens come by the time that passed.

/** `rate` tokens a second, `burst` at most (a bucket starts full). */
export type Rule = { rate: float; burst: float };

/** A bucket's tokens, and when it was last looked at (ms: `performance.now()`, or any clock of
 * milliseconds that does not go back). */
export type Bucket = { tokens: float; at: float };

/** Bucket `b` (null: a new one, full) asked for `n` tokens at `now` under `r`: whether it gave them,
 * and the bucket after. */
export function take(b: Bucket | null, r: Rule, now: float, n: float = 1.0): [bool, Bucket] {
  const was = b ?? { tokens: r.burst, at: now };
  const tokens = Math.min(r.burst, was.tokens + ((now - was.at) * r.rate) / 1000.0);
  if (tokens >= n) return [true, { tokens: tokens - n, at: now }];
  return [false, { tokens, at: now }];
}

/** Whether bucket `b` is full again by `now`: it says nothing more than a new one, and may be
 * forgotten. */
export function full(b: Bucket, r: Rule, now: float): bool {
  return b.tokens + ((now - b.at) * r.rate) / 1000.0 >= r.burst;
}
