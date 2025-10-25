FROM node:24-bullseye-slim AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

ARG BUILDDIR=/migration
WORKDIR ${BUILDDIR}

COPY package.json package.json
COPY package-lock.json package-lock.json

RUN npm install && npm cache clean --force

FROM node:24-bullseye-slim

ARG BUILDDIR=/migration
WORKDIR ${BUILDDIR}

COPY --from=builder /migration/package.json package.json
COPY --from=builder /migration/package-lock.json package-lock.json
COPY --from=builder /migration/node_modules node_modules
COPY prisma prisma

CMD ["npx", "prisma", "migration", "deploy"]
