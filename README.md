# Product-Meta

Component and product meta info for Transwarp Data Cloud.

## Project structure

This project contains the configurable parts of Transwarp Data Cloud.
It covers the static assets (images, htmls etc.), big-data products/applications, image releases, service configurations, and upgrading and development utilities shipped with official TDC edition.

### Static assets
Including folders:
* `assets`: static resources for configurable TDC UI.

### Products and components
Including folders:
* `products`: official big-data products definitions
* `components`: official components definitions

### Image releases
Including folders:
* `instances`: offical releases' images and dependencies

### Service configurations
Including folders:
* `etc/ockle`: configurations for cluster management service
* `resources`: configurations for billing service
* `system_contenxts`: configurations for tenant contenxt services
* `upgrade`: configurations for upgrading service

### Utilities
Including folders;
* `script`: useful tools for cluster operations
* `tests`: development tools for testing

## Devlopment

* Add new configurations WITHOUT breaking released logic
* run `./testing.sh` for validation
