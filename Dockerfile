FROM node:22-bookworm-slim AS build

ARG GLEAM_VERSION=1.17.0

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl git \
  && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --silent --show-error \
  "https://github.com/gleam-lang/gleam/releases/download/v${GLEAM_VERSION}/gleam-v${GLEAM_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  | tar -xz -C /usr/local/bin gleam

WORKDIR /app

COPY package.json ./
COPY frontend/package.json ./frontend/package.json
COPY frontend/elm.json ./frontend/elm.json
RUN npm install

COPY . .
RUN npm run build

FROM node:22-bookworm-slim AS runtime

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

CMD ["node", "/app/backend/build/dev/javascript/kernel_desk/gleam@@private_main_v1.17.0.mjs"]
