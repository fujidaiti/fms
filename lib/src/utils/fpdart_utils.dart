import 'package:fpdart/fpdart.dart';

extension ApplyEither2<R1, R2, T> on T Function(R1, R2) {
  Either<Iterable<L>, T> applyEithers<L>(
    Either<L, R1> m1,
    Either<L, R2> m2,
  ) =>
      m1
          .flatMap(
            (r1) => m2.map(
              (r2) => this(r1, r2),
            ),
          )
          .mapLeft(
            (_) => [m1, m2].whereType<Left<L, dynamic>>().map((e) => e.value),
          );
}

extension ApplyEither4<R1, R2, R3, R4, T> on T Function(R1, R2, R3, R4) {
  Either<Iterable<L>, T> applyEithers<L>(
    Either<L, R1> m1,
    Either<L, R2> m2,
    Either<L, R3> m3,
    Either<L, R4> m4,
  ) =>
      m1
          .flatMap(
            (r1) => m2.flatMap(
              (r2) => m3.flatMap(
                (r3) => m4.map(
                  (r4) => this(r1, r2, r3, r4),
                ),
              ),
            ),
          )
          .mapLeft(
            (_) => [m1, m2, m3, m4]
                .whereType<Left<L, dynamic>>()
                .map((e) => e.value),
          );
}

extension ApplyEither5<R1, R2, R3, R4, R5, T> on T Function(
    R1, R2, R3, R4, R5) {
  Either<Iterable<L>, T> applyEithers<L>(
    Either<L, R1> m1,
    Either<L, R2> m2,
    Either<L, R3> m3,
    Either<L, R4> m4,
    Either<L, R5> m5,
  ) =>
      m1
          .flatMap(
            (r1) => m2.flatMap(
              (r2) => m3.flatMap(
                (r3) => m4.flatMap(
                  (r4) => m5.map(
                    (r5) => this(r1, r2, r3, r4, r5),
                  ),
                ),
              ),
            ),
          )
          .mapLeft(
            (_) => [m1, m2, m3, m4, m5]
                .whereType<Left<L, dynamic>>()
                .map((e) => e.value),
          );
}
