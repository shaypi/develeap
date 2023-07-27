locals {
  image_scanning_configuration = [
    {
      scan_on_push = lookup(var.image_scanning_configuration, "scan_on_push", null) == null ? var.scan_on_push : lookup(var.image_scanning_configuration, "scan_on_push")
    }
  ]

  # Timeouts
  timeouts = var.timeouts_delete == null && length(var.timeouts) == 0 ? [] : [
    {
      delete = lookup(var.timeouts, "delete", null) == null ? var.timeouts_delete : lookup(var.timeouts, "delete")
    }
  ]
}