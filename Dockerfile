FROM docker.io/nixos/nix:latest AS build

WORKDIR /app

COPY flake.nix ./
RUN nix --extra-experimental-features "nix-command flakes" develop --command true

COPY . .
RUN nix --extra-experimental-features "nix-command flakes" develop --command npm run build

FROM docker.io/library/node:22-bookworm-slim AS runtime

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/backend /app/backend
COPY --from=build /app/sample /app/sample

ENV HOST=0.0.0.0
ENV PORT=4000
ENV KERNEL_REPO_PATH=/app/sample/linux-mini
ENV KERNEL_DESK_STATIC=/app/backend/priv/static
ENV KERNEL_DESK_DATA=/data/progress.json

EXPOSE 4000

CMD ["node", "--input-type=module", "--eval", "import('/app/backend/build/dev/javascript/kernel_desk/kernel_desk.mjs').then(({ main }) => main())"]
