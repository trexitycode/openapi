# Code samples

In this directory stores [code samples](https://github.com/Redocly/redoc/blob/main/docs/redoc-vendor-extensions.md#code-sample-object).
Each file should have the following naming convention: `<tag>/<operationId>.<lang>.yaml` where:
- `<tag>` is the name of the tag the operation is associated with as lowercase
- `<lang>` is the name of the language from [this](https://github.com/github/linguist/blob/master/lib/linguist/popular.yml) list

For example a `cURL` sample would be saved in a file like `shipments/getShipment.shell.yaml` and then referenced by an OpenAPI path spec like this:

```yaml
get:
  x-codeSamples:
    - $ref: '../../code_samples/shipments/getShipment.shell.yaml'
  # ...rest of the fields
```
