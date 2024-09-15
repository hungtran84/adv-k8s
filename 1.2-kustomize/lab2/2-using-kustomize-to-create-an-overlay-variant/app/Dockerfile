FROM node:20-alpine AS base
ARG NODE_ENV
ENV NODE_ENV="${NODE_ENV:-production}"
ARG UID=node \
    GID=node
USER $UID:$GID

FROM base AS deps
WORKDIR /app
COPY --chown=$UID:$GID package.json yarn.lock ./
RUN yarn install

FROM base
WORKDIR /app
COPY --chown=$UID:$GID . .
COPY --chown=$UID:$GID --from=deps /app/node_modules ./node_modules
CMD ["/app/docker-entrypoint.sh"]
