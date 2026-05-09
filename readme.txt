Raw C bindings are private.
Public API never exposes C pointers.
All fallible operations return Result.t.
No _exn in public API.
Every resource has explicit close.
Double-close is safe or impossible.
Integration tests run against Redpanda.
Producer delivery is acknowledged, not fire-and-forget.
