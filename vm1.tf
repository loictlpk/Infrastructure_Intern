# Packer peut etre utilisé pour créer des template à partir de isos, etc. pour vsphere
# https://blog.stephane-robert.info/docs/virtualiser/outils/packer/

# https://docs.vmware.com/fr/VMware-vSphere/8.0/vsphere-vcenter-esxi-management/GUID-302A4F73-CA2D-49DC-8727-81052727A763.html
# https://developer.hashicorp.com/terraform
# https://developer.hashicorp.com/terraform/tutorials/virtual-machine/vsphere-provider
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs
# https://registry.terraform.io/providers/ansible/ansible/latest/docs
# https://dteslya.engineer/blog/2019/01/21/automate-windows-vm-creation-and-configuration-in-vsphere-using-packer-terraform-and-ansible-part-2-of-3/
# https://github.com/dteslya/win-iac-lab/tree/master
# https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management
# https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax
# https://developer.hashicorp.com/terraform/cli
# https://github.com/hashicorp/learn-terraform-vsphere
# https://github.com/PXLCloudAndAutomation/TerraformvSphereExamples
# https://garyflynn.com/post/create-your-first-vsphere-terraform-configuration/
# https://vmware-samples.github.io/packer-examples-for-vsphere/
# https://www.osboxes.org/vmware-images/
# https://github.com/89luca89/terrible
# https://developer.vmware.com/apis/vsphere-automation/latest/

# https://ilhicas.com/2019/08/17/Terraform-local-exec-run-always.html
# https://stackoverflow.com/questions/69185881/terraform-vsphere-new-template-re-creating-existing-vms
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine

# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine.html#guest_id
# identification OS de la VM "guest_id": https://vdc-repo.vmware.com/vmwb-repository/dcr-public/184bb3ba-6fa8-4574-a767-d0c96e2a38f4/ba9422ef-405c-47dd-8553-e11b619185b2/SDK/vsphere-ws/docs/ReferenceGuide/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
#  OU : https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/api/vcenter/vm/vm/get/

# version vSphere : 6.7

# en insérant vsphere comme provider, on lui fournit en réalité une API

# PREFERE L'UTILISATION DES SENSITIVES VARIABLES : soit avec export soit avec un ficher de variables externe
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables
# https://stackoverflow.com/questions/63829249/encrypt-environment-variable-and-call-it-in-the-terraform-code

# Les variables n'ont pas de valeurs car elles sont exportées dans le script du runner. Il faut juste les déclarées avec le type string
variable "vsphere_user" {
  type = string
}
variable "vsphere_password" {
  type = string
}
variable "vsphere_domain" {
  type = string
}

provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_domain
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "GAIA"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "TESTBED"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name = "FREENAS_STORAGE_1_A"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name = "STAFF_VM" 
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Specifier le template
data "vsphere_virtual_machine" "template" {
  name = "Templates/[TEMPLATE] Debian 11 Update 1 - Stage Ansible Loic" # En réalité : /<nom_datacenter>/dossier1/.../<nom_template>
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Creation VM
resource "vsphere_virtual_machine" "vm" {
  name = "LOIC_VM"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  num_cpus = 2
  memory = 4096
  guest_id = "debian9_64Guest" #API VMWARE : ATTENTION VERSION MAX 6.7 && doit être le même que le template (sinon => voir message erreur)
  scsi_type = "pvscsi"

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label       = "disk0"
    size        = "60"
    unit_number = 0
  }
  
  clone{
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}


# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# https://ilhicas.com/2019/08/17/Terraform-local-exec-run-always.html
# RUN Ansible playbook à chaque execution terraform

# COMMANDE : $ ansible-playbook ansible/playbooks/entrypoint.yml 
# resource "null_resource" "run_playbook" {
#   provisioner "local-exec" {
#     command = "ansible-playbook ./ansible/playbooks/entrypoint.yml"
#   }
#   triggers = {
#     always_run = "${timestamp()}" # LE TIMESTAMP PERMET D'EXECUTER AU MOMENT "T"
#   }    
# }

# https://fabianlee.org/2019/03/09/vmware-using-the-govc-cli-to-automate-vcenter-commands/
# https://github.com/vmware/govmomi?tab=readme-ov-file

  # # vCenter host
  # $ export GOVC_URL=myvcenter.name.com
  
  # # vCenter credentials
  # $ export GOVC_USERNAME=myuser
  # $ export GOVC_PASSWORD=MyP4ss

  # # disable cert validation
  # $ export GOVC_INSECURE=true

# resource "null_resource" "power" {
#   provisioner "local-exec" {
#     command = "govc vm.power -on=true ${vsphere_virtual_machine.vm.name}"
#   }
#   triggers = {
#     always_run = "${timestamp()}" # LE TIMESTAMP PERMET D'EXECUTER AU MOMENT "T"
#   }    
# }
