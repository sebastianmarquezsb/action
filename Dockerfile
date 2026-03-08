FROM node:latest
COPY . .
RUN npm install
CMD ["npm","start"]


# --- STAGE 1: BASE (compartida entre ci-stage y cd-stage) ---
FROM node:20 AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# --- STAGE 2: CI (para testing y análisis) ---
FROM node:20 AS ci-stage
WORKDIR /app
COPY . .
RUN npm ci
# Aquí van tus comandos de test/lint si los tienes
# RUN npm run lint
# RUN npm run test

# --- STAGE 3: CD (para producción) ---
FROM base AS cd-stage
COPY --from=ci-stage /app/node_modules ./node_modules
COPY . .
CMD ["npm", "start"]