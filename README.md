# Quadient ACR Starter Scripts

This repository provides a set of starter scripts for working with the select set
of [Quadient](https://www.quadient.com/en/customer-communications/inspire-flex)
-built container images hosted in the Azure Container Registry (ACR) service.

## Getting Started

### Prerequisites

- Azure CLI 2.42.0+
- Quadient-issued ACR credentials

The scripts in this repository leverage the functionality provided by the
[Azure Command-line Interface](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
(CLI) tools and have been tested with version 2.42.0. Newer versions are expected
to work without issue.

A unique set of credentials for the Quadient ACR service is also required.
Credentials can be requested via
[Quadient University](https://university.quadient.com/group/site/product-installers?p_p_id=com_quadient_university_installers_display_portlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_com_quadient_university_installers_display_portlet_cur2=1&_com_quadient_university_installers_display_portlet_delta2=20&_com_quadient_university_installers_display_portlet_orderByCol=created-date&_com_quadient_university_installers_display_portlet_orderByType=desc&_com_quadient_university_installers_display_portlet_navigationBar=container-registry).

### Installation

To begin, clone the repository:

```bash
git clone https://github.com/robertwtucker/quadient-acr-starter.git acr
```

The command above clones the repository into a directory named `acr` instead of
using the default (repository name).

Switch to the `acr` directory that was created and edit the `acr-creds-template.env`
file. Add your unique credentials to the `ACR_USERNAME=` and `ACR_PASSWORD=`
lines, respectively, and **save the file as** `acr-creds.env` in the `acr`
directory.

## Usage

All of the scripts provided will display usage information if the the `-h` or
`--help` options are used. A few usage examples are included below.

### Listing the repositories

To see the complete list of repositories hosted in Quadient's ACR, run the
`list-repos.sh` script:

```bash
$ ./list-repos.sh

Repositories available at quadientdistribution.azurecr.io:

Result
--------------------
flex/automation
flex/icm
flex/interactive
flex/ips
flex/scaler
flex/scenario-engine
```

### Displaying the tags for a product repository

To display the tags available for a particular product (Inspire Scaler, in this
example), run the `show-tags.sh` script:

```bash
$ ./show-tags.sh --limit 8 scaler

Image: quadientdistribution.azurecr.io/flex/scaler

Tags
-------------
./show-tags.sh --limit 8 scaler

Image: quadientdistribution.azurecr.io/flex/scaler

Tags
-------------
15.0-latest
15.0.774.0-HF
17.0-latest
17.0.409.0-HF
16.0-latest
16.0.652.0-SP
16.0.651.0-HF
16.0.650.0-HF
```

The products valid for the current version of the `show-tags.sh` script are:
`icm` (default), `interactive`, `ips`, `scaler`, `scenario-engine` and `automation`.
In the example above, the `--limit` option is used to restrict the output to the
8 most recently published tags. If no limit is specified, the 10 most recent
tags are listed by default.

### Filtering the tags shown for a product

To see tags that contain a particular string, use the `filter-tags.sh` script:

```bash
$ ./filter-tags.sh icm 16.0

Image: quadientdistribution.azurecr.io/flex/icm:16.0

Tags
-------------
16.0-latest
16.0.755.0-HF
16.0.754.0-HF
16.0.753.0-HF
16.0.752.0-SP
```

The products valid for the current version of the `filter-tags.sh` script are:
`icm` (default), `interactive`, `ips`, `scaler`, `scenario-engine` and `automation`.
If no version string is provided, `17.0` is used as the default. As with the
[`show-tags.sh` script](#displaying-the-tags-for-a-product-repository), the
output is limited to the 10 most recently published tags by default.

### Logging into the ACR with Docker/Podman

In order to pull images from the Quadient ACR, you must first authenticate using
your preferred [Open Container Initiative](https://opencontainers.org) (OCI)
command-line tool. The `acr-login.sh` script simplifies this process by
supplying the credentials for the `docker` and `podman login` commands,
respectively.

```bash
$ ./acr-login.sh --podman

Logging into quadientdistribution.azurecr.io with Podman...

Login Succeeded!
```

The example above uses the `--podman` option to specify that the
[Podman](https://podman.io) client should be used. If no option is provided,
the script defaults to using [Docker](https://www.docker.com) (`--docker`).

### Downloading images from the Quadient ACR

Once an image has been identified for testing, best practice is to pull the
image locally before pushing it to a internally-managed repository. While not
mandatory, this is highly recommended for quarantine and/or manageability
purposes. The `get-image.sh` script was created to support such a scenario.

> _NOTE_: Quadient R&D recommends that images from the Quadient ACR only be
> pulled directly into Kubernetes clusters for proofs-of-concept (i.e. as
> referenced by the default configuration of the Inspire Helm charts).

```bash
$ ./get-image.sh --push --registry registry.example.com scaler 15.5.414.0-HF

Logging into quadientdistribution.azurecr.io with Docker...
Login Succeeded

Pulling image: quadientdistribution.azurecr.io/flex/scaler:15.5.414.0-HF
15.5.414.0-HF: Pulling from flex/scaler
Digest: sha256:a9cca6c559ee95df20f2902a287d978040afcb4fc866c08ef4b61e2df40481f4
Status: Downloaded newer image for quadientdistribution.azurecr.io/flex/scaler:15.5.414.0-HF

Tagging image as: registry.example.com/flex/scaler:15.5.414.0-HF
Removing tag: quadientdistribution.azurecr.io
Untagged: quadientdistribution.azurecr.io/flex/scaler:15.5.414.0-HF
Untagged: quadientdistribution.azurecr.io/flex/scaler@sha256:a9cca6c559ee95df20f2902a287d978040afcb4fc866c08ef4b61e2df40481f4

Pushing image: registry.example.com/flex/scaler:15.5.414.0-HF
The push refers to repository [registry.example.com/flex/scaler]
15.5.414.0-HF: digest: sha256:a9cca6c559ee95df20f2902a287d978040afcb4fc866c08ef4b61e2df40481f4
```

In the preceeding example, the script starts by leveraging the
[`acr-login.sh` script](#logging-into-the-acr-with-dockerpodman) to authenticate
with the Quadient ACR. The `--registry` option provides the name of an
OCI-compliant registry that will replace the one on the image provided by the
Quadient ACR (`quadientdistribution.azurecr.io`). This is used in conjunction
with the `--push` option to automatically upload the image to the
newly-specified registry.

The products valid for the current version of the `get-image.sh` script are:
`icm` (default), `interactive`, `ips`, `scaler`, `scenario-engine` and `automation`.
If no image tag is provided, `17.0-latest` is used as the default. As with the
[`acr-login.sh` script](#logging-into-the-acr-with-dockerpodman), the Docker
client (`--docker`) is specified by default.

## Roadmap

See the [open issues](https://github.com/robertwtucker/quadient-acr-starter/issues)
for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to
be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Copyright (c) 2022 Quadient Group AG and distributed under the MIT License.
See `LICENSE` for more information.

## Contact

Robert Tucker - [@robertwtucker](https://twitter.com/robertwtucker)

Project Link: [https://github.com/robertwtucker/quadient-acr-starter](https://github.com/robertwtucker/quadient-acr-starter)
