# Product-Meta

Organizing products' and components' meta info, including default configurations and price info etc.

Based on [application-jsonent](http://172.16.1.41:10080/TDC/application-jsonnet).


## Folders

<pre>
product-meta
|___ components: Official applications
|___ products: Official TDC products
|___ system_components: Official TDC platform applications
|___ system_contexts: Official TDC platform distributions
|___ dependencies: Application dependency management used by `libappadapter`
|___ instances: Instance-specific settings
     |___ instance_advanced_configs: Advanced configs of each instance
|___ etc
     |___ ockle: Configuration management
</pre>

## Contribution

* Add new configurations WITHOUT breaking released logic
* run `./testing.sh` for validation

## Contact

* xiaming.chen@transwarp.io
