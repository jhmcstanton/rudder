# Shared Example

This example is a bit contrived, but serves to illustrate how joining pipelines works.

[`common.pipeline`](./common.pipeline) is a full, standalone pipeline with resources
and several jobs that is fully flyable.

[`wrapper.pipeline`](./wrapper.pipeline) is another full pipeline that incorporates
the entirety of `common.pipeline` and augments it with an additional timer, one new
job that requires the final job from `common.pipeline`, and its own job that only
depends on a single resource from the common pipeline.


[`borrows.pipeline`](./borrows.pipeline) is a single job pipeline that borrows
the git resource from the `common.pipeline` (actually, it would borrow any git
resource from that pipeline, there just happens to be only one right now).
