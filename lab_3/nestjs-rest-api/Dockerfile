FROM node:18.14.0-slim AS build

COPY package*.json src/

WORKDIR /src

RUN npm ci

COPY . .

RUN npm run build

FROM build AS prune

RUN npm prune --production --verbose

FROM node:18.14.0-slim

EXPOSE 3000

WORKDIR /app

USER node

COPY --from=prune /src/node_modules node_modules
COPY --from=build /src/dist dist
COPY --from=build /src/package.json .

ENTRYPOINT [ "npm" ]
CMD [ "run", "start:prod" ]
