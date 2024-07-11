# Kubernetes Walkthrough

To get started with tails, you'll need at least the remotetap processor and optionally the opamp extension. You can view the collector.yaml file for a complete example YAML file that works with the OpenTelemetry Operator, this will also work with a non-operator collector.

> [!NOTE]
> Be sure you are using at least collector version 0.103.0

## Add Remote Tap Processor

```yaml
processors:
  remotetap:
    endpoint: localhost:12001
```

## (Optional) Add OpAMP Extension

```yaml
extensions:
  opamp:
    server:
      ws:
        endpoint: ws://127.0.0.1:4000/v1/opamp
        tls:
          insecure: true
```

## Update service pipeline(s)

The remote tap processor's placement in the pipeline is important. If you want to see all the un-filtered data put it first in the pipeline. If you want to see the data post-filtering and enrichment put it last.

```yaml
service:
  extensions: [opamp]
  pipelines:
    traces:
      processors: [..., remotetap]
```

## Add the additional tails container

> [!WARNING]
> It's recommended to replace the SECRET_KEY_BASE with a randomly generated 64 byte string. You can do this with `openssl rand -base64 64`

```yaml
additionalContainers:
  - name: tails
    image: ghcr.io/jaronoff97/tails:v0.0.8
    env:
      - name: SECRET_KEY_BASE
        value: nErlTbssfnJxvjjujVKgDO/q84XAggf6/kN6b926qjRFK+uasVyd/+oACdXLm38l
    ports:
      - containerPort: 4000
```

## Apply your new config

Apply the configuration either via `kubectl apply -f <file>` or with helm.

## Port forward to view the UI

```bash
kubectl port-forward pod/<collector-pod> 4000:4000
```

You should now be able to visit http://localhost:4000
