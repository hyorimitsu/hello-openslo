Hello OpenSLO
---

This is sample of [OpenSLO](https://github.com/OpenSLO/OpenSLO), an open specification for defining SLOs.


## Description

This is a sample of using [OpenSLO](https://github.com/OpenSLO/OpenSLO) and [Sloth](https://github.com/slok/sloth) to pull API metrics in [Prometheus](https://github.com/prometheus/prometheus) and visualize them in [Grafana](https://github.com/grafana/grafana).

![architecture](https://github.com/hyorimitsu/hello-openslo/blob/main/doc/img/architecture.png)


## Structure

### Used language, tools, and other components

| language/tools | description |
| --- | --- |
| [OpenSLO](https://openslo.com/) | open specification for defining SLOs |
| [Sloth](https://sloth.dev/) | SLO generator for Prometheus |
| [Prometheus](https://prometheus.io/) | monitoring system |
| [Grafana](https://grafana.com/) | analytics & monitoring visualization system |
| [Go](https://github.com/golang/go)  | programming language |
| [Kubernetes](https://kubernetes.io/) | container orchestrator |
| [Skaffold](https://skaffold.dev/) | tool for building, pushing and deploying your application |

### Directories

```
.
├── .k8s           # => Kubernetes manifests
│   ├── base
│   └── overlays
├── .openslo       # => OplenSLO definitions
├── api            # => API implementation
├── skaffold.yaml
└── (some omitted)
```


## Usage

### Run and setup the application

1. Run the application in minikube

  ```shell
  make run
  ```

2. Confirm Prometheus

  - Access the following URL to confirm if the rules described by OpenSLO are applied.

    http://hello-openslo.localhost.com/prometheus/rules

    ![img]()

  - Access the following URL to confirm if the targets are applied.

    http://hello-openslo.localhost.com/prometheus/targets

    ![img]()

3. Setup Grafana

  - Access the following URL and login to Grafana.

    http://hello-openslo.localhost.com/grafana/login

    | - | How to Confirm |
    | --- | --- |
    | username | `kubectl get secret -n hello-openslo hello-openslo-grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo` |
    | password | `kubectl get secret -n hello-openslo hello-openslo-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo` |

  - Specify Prometheus as the data source.

    http://hello-openslo.localhost.com/grafana/datasource

    ![img]()

  - Import the dashboard provided by Sloth.

    http://hello-openslo.localhost.com/grafana/import

    | Field | Value |
    | --- | --- |
    |  | http://hello-openslo.localhost.com/prometheus |
    |  | 14348 (see [here](https://sloth.dev/introduction/dashboards/)) |

    ![img]()

4. API calls at 1s intervals

  ```shell
  make call-api
  ```

5. Confirm Grafana

  - Access the following URL to confirm the status of API access

    http://hello-openslo.localhost.com/grafana/dashboard

    ![img]()

    ※ You will need to wait a while for the data to be collected.

6. Down the application in minikube

  ```shell
  make down
  ```

### Update OpenSLO settings

1. Update OpenSLO format YAML

  - Edit the following file

    https://github.com/hyorimitsu/hello-openslo/blob/main/.openslo/slo.yaml

2. Generate Prometheus format YAML

  - Execute generate command

    ```shell
    make sloth-gen
    ```

    The above command will generate file in the following directory.

    https://github.com/hyorimitsu/hello-openslo/tree/main/.openslo/generated

  - Copy and paste in k8s manifest

    I'm not sure how to load an external YAML file, the file is updated manually by copying and pasting.

    Please paste the generated results into the following file.

    https://github.com/hyorimitsu/hello-openslo/blob/main/.k8s/base/prometheus/values.yaml

3. Run the application in minikube

  Please refer to the following URL to start the application and confirm SLI/SLO.

  https://github.com/hyorimitsu/hello-openslo#run-and-setup-the-application


## Troubleshoot

- Q1: I get a redirect loop on grafana login.

  A1: Please delete all cookies related to Grafana.

- Q2: Cannot start with the following error output.

  ```shell
  - pods: could not stabilize within 10m0s
  - pods failed. Error: could not stabilize within 10m0s.
  ```

  A2: It is a problem with Prometheus, try `make run` again without `make down`.

- Q3: Cannot start with the following error output.

  ```shell
  - pods: container hello-openslo-grafana-test terminated with exit code 1
      - hello-openslo:pod/hello-openslo-grafana-test: container hello-openslo-grafana-test terminated with exit code 1
        > [hello-openslo-grafana-test hello-openslo-grafana-test] 1..1
        > [hello-openslo-grafana-test hello-openslo-grafana-test] not ok 1 Test Health
        > [hello-openslo-grafana-test hello-openslo-grafana-test] # (in test file /tests/run.sh, line 5)
        > [hello-openslo-grafana-test hello-openslo-grafana-test] #   `[ "$code" == "200" ]' failed
  - pods failed. Error: container hello-openslo-grafana-test terminated with exit code 1.
  ```

  A3: It is a problem with Prometheus, try `make run` again without `make down`.

- Q4: Cannot start with the following error output.

  ```shell
  Error from server (InternalError): error when creating "STDIN": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": failed to call webhook: Post "https://ingress-nginx-controller-admission.ingress-nginx.svc:443/networking/v1/ingresses?timeout=10s": dial tcp 10.110.199.7:443: connect: connection refused
  ```

  A4: It is a problem with Ingress, try `make run` again.
