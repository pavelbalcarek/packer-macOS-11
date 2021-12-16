packer {
  required_version = ">= 1.7.0"
}

variable "iso_file_checksum" {
  type    = string
  default = "file:install_bits/macOS_1120_installer.shasum"
}

variable "iso_filename" {
  type    = string
  default = "install_bits/macOS_1120_installer.iso"
}

variable "user_password" {
  type    = string
  default = "packer"
}

variable "user_username" {
  type    = string
  default = "packer"
}

variable "cpu_count" {
  type    = number
  default = "2"
}

variable "ram_gb" {
  type    = number
  default = "6"
}

variable "xcode_cli" {
  type    = string
  default = "install_bits/Command_Line_Tools_for_Xcode_13.1.dmg"
}

variable "board_id" {
  type    = string
  default = "Mac-27AD2F918AE68F61"
}

variable "hw_model" {
  type    = string
  default = "MacPro7,1"
}

variable "serial_number" {
  type    = string
  default = "M00000000001"
}

variable "snapshot_linked" {
  type    = bool
  default = false
}

# Set this to DeveloperSeed if you want prerelease software updates
variable "seeding_program" {
  type    = string
  default = "none"
}

variable "boot_key_interval_iso" {
  type    = string
  default = "150ms"
}

variable "boot_wait_iso" {
  type    = string
  default = "300s"
}

variable "boot_keygroup_interval_iso" {
  type    = string
  default = "4s"
}

variable "macos_version" {
  type    = string
  default = "12.0"
}

variable "bootstrapper_script" {
  type    = list(string)
  default = ["sw_vers"]
}

variable "headless" {
  type = bool
  default = false
}

variable "vrdp_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vrdp_port_min" {
  type    = string
  default = "5900"
}

variable "vrdp_port_max" {
  type    = string
  default = "6000"
}

variable "vrdp_status" {
  type    = string
  default = "off"
}

variable "http_bind_address" {
  type    = string
  default = "127.0.0.1"
}

# source from iso
source "virtualbox-iso" "macOS" {
  headless             = "${var.headless}"
  vrdp_bind_address     = "${var.vrdp_bind_address}"
  vrdp_port_min         = "${var.vrdp_port_min}"
  vrdp_port_max         = "${var.vrdp_port_max}"
  vm_name              = "{{build_name}}_${var.macos_version}_base"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}_${var.macos_version}_base"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "MacOS_64"
  iso_interface        = "sata"
  disk_size            = "40960"
  hard_drive_interface = "sata"
  http_directory       = "http"
  http_bind_address    = "${var.http_bind_address}"
  ssh_timeout          = "12h"
  usb                  = "true"
  communicator         = "ssh"
  guest_additions_mode = "disable"
  sata_port_count      = 2
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  vboxmanage           = [
    ["modifyvm", "{{ .Name }}", "--vram", "128"],
    ["modifyvm", "{{ .Name }}", "--graphicscontroller", "vboxvga"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "off"],
    ["modifyvm", "{{ .Name }}", "--nestedpaging", "on"],
    ["modifyvm", "{{ .Name }}", "--apic", "on"],
    ["modifyvm", "{{ .Name }}", "--pae", "on"],
    ["modifyvm", "{{ .Name }}", "--audiocontroller", "hda"],
    ["modifyvm", "{{ .Name }}", "--boot1", "dvd"],
    ["modifyvm", "{{ .Name }}", "--boot2", "disk"],
    ["modifyvm", "{{ .Name }}", "--chipset", "ICH9"],
    ["modifyvm", "{{ .Name }}", "--firmware", "EFI"],
    ["modifyvm", "{{ .Name }}", "--hpet", "on"],
    ["modifyvm", "{{ .Name }}", "--usbxhci", "off"],
    ["modifyvm", "{{ .Name }}", "--keyboard", "usb"],
    ["modifyvm", "{{ .Name }}", "--mouse", "usbtablet"],
    ["modifyvm", "{{ .Name }}", "--vrde", "${var.vrdp_status}"],
    ["modifyvm", "{{ .Name }}", "--rtcuseutc", "on"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "on"],
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
    ["modifyvm", "{{ .Name }}", "--cpuidset", "00000001", "000106e5", "00100800", "0098e3fd", "bfebfbff"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct", "${var.hw_model}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion", "1.0"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct", "${var.board_id}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiBoardSerial", "${var.serial_number}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/smc/0/Config/DeviceKey", "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC", "1"],
    ["setextradata", "{{ .Name }}", "VBoxInternal2/EfiGraphicsResolution", "1920x1080"]
  ]
  vboxmanage_post      = [
    [ "storageattach", "{{.Name}}", "--storagectl", "IDE Controller", "--port", "1", "--device", "0", "--medium", "none" ]
  ]
  boot_wait              = var.boot_wait_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "<leftCtrlon><f2><leftCtrloff>",
    "w<down><down>",
    "<enter>",
    "curl -o /var/root/packer.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/packer.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
}

# Customize build from existing vm
source "virtualbox-ovf" "macOS" {
  headless             = "${var.headless}"
  vrdp_bind_address     = "${var.vrdp_bind_address}"
  vrdp_port_min         = "${var.vrdp_port_min}"
  vrdp_port_max         = "${var.vrdp_port_max}"
  vm_name          = "{{build_name}}_${var.macos_version}"
  ssh_username     = "${var.user_username}"
  ssh_password     = "${var.user_password}"
  boot_wait        = "30s"
  skip_compaction  = true
  linked           = var.snapshot_linked
  source_path      = "output/{{build_name}}_${var.macos_version}_base/macOS_${var.macos_version}_base.vmx"
  shutdown_command = "sudo shutdown -h now"
  output_directory = "output/{{build_name}}_${var.macos_version}"
  vmx_data = {
    "nvram" = "../../scripts/disablesip.nvram"
  }
  vmx_data_post = {
    "nvram" = "{{build_name}}_${var.macos_version}.nvram"
  }
}

# Base build
build {
  name = "base"
  sources = [
    "sources.virtualbox-iso.macOS"
  ]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }
}

build {
  name    = "customize"
  sources = ["sources.virtualbox-ovf.macOS"]

  provisioner "file" {
    sources     = [var.xcode_cli, "submodules/tccutil/tccutil.py", "files/cliclick"]
    destination = "~/"
  }

  provisioner "shell" {
    environment_vars = [
      "USER_PASSWORD=${var.user_password}"
    ]
    expect_disconnect = true
    script            = "scripts/os_configure.sh"
  }

  provisioner "shell" {
    expect_disconnect   = true
    start_retry_timeout = "2h"
    environment_vars = [
      "SEEDING_PROGRAM=${var.seeding_program}"
    ]
    scripts = [
      "scripts/xcode.sh",
      "scripts/softwareupdate.sh",
      "scripts/softwareupdate_complete.sh"
    ]
  }

  # optionally call external bootstrap script set by var.bootstrapper_script
  provisioner "shell" {
    expect_disconnect = true
    inline            = var.bootstrapper_script
  }

  post-processor "shell-local" {
    inline = ["scripts/vmx_cleanup.sh output/{{build_name}}_${var.macos_version}/macOS_${var.macos_version}.vmx"]
  }
}
