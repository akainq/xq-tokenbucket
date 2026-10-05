// A bucket of three tokens, ten a second: three requests at once take them, a fourth is refused; 100 ms
// later one more is given; long after, three at once again, and a fourth not. Asked for 0.5, a bucket
// with one gives it; one emptied below zero (a penalty) waits until it fills. A bucket full again is no
// different from a new one.
import * as tokenbucket from "../lib";

function main(): void {
  const r: tokenbucket.Rule = { rate: 10.0, burst: 3.0 };
  const [a1, b1] = tokenbucket.take(null, r, 0.0);
  const [a2, b2] = tokenbucket.take(b1, r, 0.0);
  const [a3, b3] = tokenbucket.take(b2, r, 0.0);
  const [a4, b4] = tokenbucket.take(b3, r, 0.0);
  const [a5, b5] = tokenbucket.take(b4, r, 100.0);
  const [a6, b6] = tokenbucket.take(b5, r, 10000.0, 3.0);
  const [a7, _] = tokenbucket.take(b6, r, 10000.0);
  console.log(
    "a bucket of three:",
    [a1, a2, a3, a4],
    "| 100 ms later:",
    a5,
    "| long after, three:",
    a6,
    "a fourth:",
    a7,
  );
  const [half, _h] = tokenbucket.take({ tokens: 1.0, at: 0.0 }, r, 0.0, 0.5);
  const below: tokenbucket.Bucket = { tokens: -2.0, at: 0.0 };
  const [soon, _s] = tokenbucket.take(below, r, 200.0);
  const [later, _l] = tokenbucket.take(below, r, 300.0);
  console.log("half a token:", half, "| two below zero, 200 ms later:", soon, "300 ms later:", later);
  console.log(
    "emptied, full again 300 ms later:",
    tokenbucket.full(b4, r, 300.0),
    "200 ms later:",
    tokenbucket.full(b4, r, 200.0),
  );
}
