[![license](https://gitlab.phaidra.org/fair-data-austria-db-repository/fda-services/-/raw/master/.gitlab/license.svg)](https://opensource.org/licenses/Apache-2.0)

# Hands on Cloud Native

Coursework startup

## Important Links

* [Code Repository](https://gitlab.phaidra.org/fair-data-austria-db-repository/fda-services)
* [Value Proposition](https://colab.tuwien.ac.at/display/ADLS/DBRepo+-+Database+Repository)
* [Wiki](https://gitlab.phaidra.org/fair-data-austria-db-repository/fda-services/-/wikis/home)

## Branching Strategy
[Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) is used as Branching Strategy.
For now, no release branch exists, as there have been no releases yet.

Following branches are used:
  - `main`: Main branch, contains the latest stable version of the application
  - `dev`: Development branch, contains the latest development version of the application
  - `feature/\<feature-name\>`: Feature branches, contain the development of a specific feature

## Versioning Scheme and Releases
[Semantic Versioning](https://semver.org/) is used as Versioning Scheme.
The application is deployed using [Helm](https://helm.sh/). The Helm Chart is located in the `helm` directory.

Changes are documented as Changelogs inside the github wiki.

### Releases

## Installation

### Locally using docker compose
The application can be launched locally using docker-compose for testing purposes as described in [dbrepo setup](https://www.ifs.tuwien.ac.at/infrastructures/dbrepo/get-started/).

```bash
# Download the docker-compose.yml and .env files:
curl -o docker-compose.yml \
  https://gitlab.phaidra.org/fair-data-austria-db-repository/fda-services/-/raw/master/docker-compose.prod.yml
curl -o .env \
  https://gitlab.phaidra.org/fair-data-austria-db-repository/fda-services/-/raw/master/.env.unix.example

# Start the services:
docker compose up -d
```


### Production using Helm

For production use, the application is deployed using [Helm](https://helm.sh/). The Helm Chart is located in the `helm` directory. In the future details will also be included in [dbrepo setup](https://www.ifs.tuwien.ac.at/infrastructures/dbrepo/get-started/).

```bash
HELM_REPO_RELEASE=https://austriandatalab.github.io/dbrepo
APP_NAME=dbrepo
APP_NS=dbrepo

helm repo add ${APP_NAME} ${HELM_REPO_RELEASE}
helm repo update
helm upgrade --install ${APP_NAME} -n ${APP_NS} ${APP_NS}/${APP_NAME} --create-namespace --cleanup-on-fail
```


## Required Cloud Resources

* Kubernetes Cluster
  - Dev: https://rancher.caas-0012.dev.austrianopencloudcommunity.org/
  - Beta: https://rancher.caas-0012.beta.austrianopencloudcommunity.org/
* Managed *high-availability* databases -or- shareded databases

## Contributors

- Martin Weise (CEO)
- Tobias Grantner (COO)
- Lukas Mahler (CIO)
- Josef Taha (CTO)
