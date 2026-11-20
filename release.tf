# The release of this module. The release workflow writes its number here when
# it publishes the module, so the module runs the server image of its own
# release. In the Flowrensic repo it holds no number, and the module runs latest.
locals {
  release   = "0.6.84"
  image_tag = coalesce(var.image_version, can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", local.release)) ? local.release : "latest")
}
