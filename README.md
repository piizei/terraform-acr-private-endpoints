# terraform-acr-private-endpoints
Azure container registry with private access and geo-replication Terraform

This is not a module, it is intentionally under-engineered example how to Geo-replicate private Azure Container Registry.

It includes:
* Geo-replicated Azure Container Registry with Private Access
* Private DNS in Hub of Hub-Spoke network topology
* Private links from container registry to spokes

It creates 2 VMs for testing, one for each spoke. This means it will cost something to deploy this (though the VMs are cheap SKUs with auto-shutdown policy). If you are unconfortable with this, just remove the terraform/vms.tf file.
