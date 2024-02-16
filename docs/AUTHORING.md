# Authoring OpenAPI Documents

There are a lot of options when it comes to authoring OpenAPI documents, not to
mention opinions on file organization practices.

We are currently still formulating our own opinions and practices, but here's what
we like using.

> IMPORTANT: After creating/releasing a new MAJOR API version create a label in the GitHub repo
> following this convention "v{MAJOR}".

> IMPORTANT: After you make changes to any OpenAPI document it's important to run `make` before you commit and push.
> The bundled spec file is created in the `dist` folder and it could be useful for other tools.

> IMPORTANT: After making a minor version bump like "v1.2" be sure add text to each new area,
> or field description that starts with the text `**(added in vX.X)**`. If you are removing
> functionality in a minor version then strike it out.

> GUIDELINE: No matter how an API is authored try to keep the model specifications in separate files at a minimum.
> This will help in the future for contract testing. Save your models in a `specs/{version}/models` folder.

## Stoplight Studio Desktop

When we want a more GUI centric, less error-prone option then we reach
for [Stoplight Studio Desktop](https://stoplight.io/studio/).

Stoplight Studio is great because the GUI makes it really easy to edit your OpenAPI documents,
find and fix problems while you're editing, and even try your endpoints with a built-in mock server
all without leaving the editor.

However, it does have a few drawbacks:

- `$ref` reference URLs cannot reference parts of a document via the `#` anchor tag.
- paths cannot reference a component within the same spec document or a file.
- responses can only reference a component within the same spec document.

## Spectral VSCode Extension

When Stoplight Studio is not cutting it we reach for our trusty IDE, VSCode. For that we want
realtime lint checking.

Spectral is a command line tool as well as a VSCode extension authored by [Stoplight.io](https://stoplight.io).
When we reach for manual editing in VSCode we like to use this extension to help lint as we edit.

To best use it, first install it, then open your root `specs/{version}/spec.yaml` file. Spectral
will crawl all referenced documents and lint them. All linting problems will be reported in the
Problems tab in VSCode.

Other VSCode extensions we've used that could be useful are:
- [OpenAPI (Swagger) Editor](https://marketplace.visualstudio.com/items?itemName=42Crunch.vscode-openapi) by 43Crunch
- [Swagger Viewer](https://marketplace.visualstudio.com/items?itemName=Arjun.swagger-viewer) by Arjun G
