# Quadient ACR Starter Scripts

This repository provides a set of starter scripts for working with the select set of Quadient-built container images hosted in the Azure Container Registry (ACR) service.

## Getting Started

### Prerequisites

* Azure CLI 2.42.0+
* Quadient-issued ACR credentials

The scripts in this repository leverage the functionality provided by the [Azure Command-line Interface](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (CLI) tools and have been tested with version 2.42.0. Newer versions are expected to work without issue.

A unique set of credentials for the Quadient ACR service is also required. Credentials can be requested via [Quadient University](https://university.quadient.com/group/site/product-installers?p_p_id=com_quadient_university_installers_display_portlet&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_com_quadient_university_installers_display_portlet_cur2=1&_com_quadient_university_installers_display_portlet_delta2=20&_com_quadient_university_installers_display_portlet_orderByCol=created-date&_com_quadient_university_installers_display_portlet_orderByType=desc&_com_quadient_university_installers_display_portlet_navigationBar=container-registry).

### Installation

To begin, clone the repository:

``` bash
git clone https://github.com/robertwtucker/quadient-acr-starter.git acr
```

The command above clones the repository into a directory named `acr` instead of using the default (repository name).

Switch to the `acr` directory that was created and edit the `acr-creds-template.env` file. Add your unique credentials to the `ACR_USERNAME=` and `ACR_PASSWORD=` lines, respectively, and **save the file as** `acr-creds.env` in the `acr` directory.

## Usage

All of the scripts provided will display usage information if the the `-h` or `--help` options are used. A few usage examples are included below.

### Listing the repositories

To see the complete list of repositories hosted in Quadient's ACR, run the `list-repos.sh` script:

``` bash
$ ./list-repos.sh

Repositories available at quadientdistribution.azurecr.io:

Result
--------------------
flex/icm
flex/interactive
flex/ips
flex/scaler
flex/scenario-engine
```

### Displaying the tags for a product repository

To display the tags available for a particular product (Inspire Scaler, in this example), run the `show-tags.sh` script:

``` bash
$ ./show-tags.sh --limit 5 scaler

Image: quadientdistribution.azurecr.io/flex/scaler

Tags
-------------
15.5-latest
15.5.414.0-HF
15.0-latest
15.0.731.0-HF
15.4-latest
```

The products valid for the current version of the `show-tags.sh` script are: `icm` (default), `interactive`, `ips`, `scaler` and `scenario-engine`. In the example above, the `--limit` option is used to restrict the output to the 5 most recently published tags. If no limit is specified, the 10 most recent tags are listed by default.

### Filtering the tags shown for a product

To see tags that contain a particular string, use the `filter-tags.sh` script:

``` bash
$ ./filter-tags.sh interactive 15.5

Image: quadientdistribution.azurecr.io/flex/interactive:15.5

Tags
-------------
15.5-latest
15.5.408.0-HF
15.5.407.0-HF
15.5.406.0-HF
```

The products valid for the current version of the `filter-tags.sh` script are: `icm` (default), `interactive`, `ips`, `scaler` and `scenario-engine`. If no version string is provided, `15.0` is used as the default. As with the `show-tags.sh` script, the output is limited to the 10 most recently published tags by default.

## Roadmap

See the [open issues](https://github.com/robertwtucker/quadient-acr-starter/issues) for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Copyright (c) 2022 Quadient Group AG and distributed under the MIT License. See `LICENSE` for more information.

## Contact

Robert Tucker - [@robertwtucker](https://twitter.com/robertwtucker)

Project Link: [https://github.com/robertwtucker/quadient-acr-starter](https://github.com/robertwtucker/quadient-acr-starter)
