# Commands

This document lists the commands used in this project.

> Before running any of the commands first install the dependencies by running
> `npm install`. You will require Node LTS installed.

## Bundling

Bundling is the process of combining all referenced OpenAPI spec documents into a single document.

To incrementally bundle the OpenAPI specifications for all API versions:

```shell
make
```

Each API version will have a `dist/{version}.json` file created or updated. These files are meant
to be committed to the repository.

## Linting

To lint a particular API version:

> Where {version} is the name of the folder under specs (defaults to v1 if not specified).

```
make lint VERSION={version}
```

Example: `make lint VERSION=v1`

## Previewing

While working on an OpenAPI spec often times it's useful to be able to preview the specification rendered as documentation.

> Where {version} is the name of the folder under specs (defaults to v1 if not specified).

```
make preview VERSION={version}
```

Example: `make preview VERSION=v1`
