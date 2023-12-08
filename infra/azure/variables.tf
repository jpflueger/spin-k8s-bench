variable "prefix" { default = "" }

variable "location" {
  default = "eastus"
  type    = string
}

variable "system_nodepool" {
  type = object({
    name = string
    size = string
    min  = number
    max  = number
  })
  default = {
    name = "agentpool"
    size = "Standard_DS2_v2"
    min  = 2
    max  = 3
  }
}

variable "user_nodepools" {
  type = list(object({
    name       = string
    size       = string
    node_count = number
    max_pods   = number
    labels     = map(string)
    taints     = list(string)
  }))
  default = [{
    name       = "npspin"
    size       = "Standard_DS2_v2"
    node_count = 1
    max_pods   = 250
    labels = {
      "func-runtime" = "spin"
    }
    taints = []
  }]
}

variable "tags" {
  description = "Map of extra tags to attach to items which accept them"
  type        = map(string)
  default     = {}
}