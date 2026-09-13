# Olympic Participation Tracker

## Context

The **Olympic Participation Tracker** is an application designed to record and analyze countries' participation in the Olympic Games. It provides statistics on medals obtained by each country, helping users gain insights into historical performance. Although the application is currently in its early development stages, we aim to create a robust and user-friendly tool for Olympic enthusiasts.

## Technical Context

The application is built using **Angular 20** and relies on **npm** for package management. Angular offers a powerful framework for creating dynamic web applications, and npm simplifies the process of managing dependencies and scripts.

Summary:

- **Node.js**: version 22 for the Docker build and version 24 in CI
- **NGINX**: used to serve the production build

## Getting Started

### Install dependencies

Run `npm i` in local development to install NodeJS dependencies. If you are installing the app on a CI environment prefer to use `npm ci`. you can also change npm cache directory to your working directory as following

```bash
npm ci --cache .npm --prefer-offline
```

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The application will automatically reload if you change any of the source files.

### Build

Run `npm run build` to build the project. The build artifacts will be stored in the `dist/` directory.

### Test

To run tests locally, use the following command:

```bash
npm test
```

For CI, `./run-tests.sh` cleans `test-results/`, runs `npm test`, and generates JUnit XML reports in that directory.

### Run with Docker

The Docker image builds the Angular application and serves it with NGINX. Start it locally with:

```bash
docker compose up --build -d
```

The application is available at `http://localhost:8081/`. Stop the local stack with `docker compose down`.

## Continuous Integration and Releases

GitHub Actions runs tests for pull requests targeting `main` and for pushes to `main`. JUnit reports are available as workflow artifacts and are published in GitHub checks.

Each push builds and publishes a Docker image to GitHub Container Registry:

```text
ghcr.io/manooweb/projet6-front:<branch>-<commit-sha>
```

On `main`, semantic-release creates GitHub releases, Git tags without a `v` prefix, and updates `CHANGELOG.md` and `package.json` when a release-worthy Conventional Commit is pushed. The corresponding Docker image is also tagged with the semantic version, for example:

```text
ghcr.io/manooweb/projet6-front:1.0.1
```

Commits of type `ci:` run the workflow but do not create a release.
