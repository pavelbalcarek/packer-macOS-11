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

variable "disk_size_gb" {
  type    = number
  default = "60"
}

variable "install_bits" {
  type    = string
  default = "install_bits"
}

variable "xcode_cli" {
  type    = string
  # path for xcode_cli in install_bits, for example: Command_Line_Tools_for_Xcode_13.1.dmg
  default = null
}

variable "xcode" {
  type    = string
  # path for xcode in install_bits, for example: Command_Line_Tools_for_Xcode_13.1.dmg
  default = null
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

variable "keep_registered" {
  type    = bool
  default = true
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
  hard_drive_interface = "sata"
  cd_label             = "cidata"
  cd_files             = ["./http/*"]
  ssh_timeout          = "12h"
  usb                  = "true"
  communicator         = "ssh"
  guest_additions_mode = "disable"
  sata_port_count      = 4
  virtualbox_version_file = ""
  firmware             = "efi"
  keep_registered      = "${var.keep_registered}"
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  disk_size            = var.disk_size_gb * 1024
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
    ["modifyvm", "{{ .Name }}", "--hpet", "on"],
    ["modifyvm", "{{ .Name }}", "--usbxhci", "off"],
    ["modifyvm", "{{ .Name }}", "--keyboard", "usb"],
    ["modifyvm", "{{ .Name }}", "--mouse", "usbtablet"],
    ["modifyvm", "{{ .Name }}", "--vrde", "${var.vrdp_status}"],
    ["modifyvm", "{{ .Name }}", "--rtcuseutc", "on"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "on"],
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
    ["storagectl", "{{ .Name }}",  "--name", "SATA Controller", "--hostiocache", "on"],
    ["modifyvm", "{{ .Name }}", "--cpuidset", "00000001", "000106e5", "00100800", "0098e3fd", "bfebfbff"],
    ["modifyvm", "{{ .Name }}", "--nictype1", "82545EM"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct", "${var.hw_model}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion", "1.0"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct", "${var.board_id}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/efi/0/Config/DmiBoardSerial", "${var.serial_number}"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/smc/0/Config/DeviceKey", "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"],
    ["setextradata", "{{ .Name }}", "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC", "1"],
    ["setextradata", "{{ .Name }}", "VBoxInternal2/EfiGraphicsResolution", "1920x1080"]
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
    "diskutil mount /dev/disk1s2<enter>",
    "cp /Volumes/cidata/bootstrap.sh /Volumes/cidata/packer.pkg /Volumes/cidata/setupsshlogin.pkg /var/root/<enter>",
    "diskutil unmount /dev/disk1s2<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
}

# Customize existing VM machine (manually imported into VirtualBox)
# This is due to issue with NVRAM, that is not imported by standard virtualbox-ovf
source "virtualbox-vm" "macOS" {
  headless          = "${var.headless}"
  vm_name           = "{{build_name}}_${var.macos_version}"
  vrdp_bind_address = "${var.vrdp_bind_address}"
  vrdp_port_min     = "${var.vrdp_port_min}"
  vrdp_port_max     = "${var.vrdp_port_max}"
  shutdown_command  = "sudo shutdown -h now"
  boot_wait         = "30s"
  communicator      = "ssh"
  ssh_username      = "${var.user_username}"
  ssh_password      = "${var.user_password}"
  output_directory  = "output/{{build_name}}_${var.macos_version}"
}

# Base build
build {
  # packer build -force -only=base.virtualbox-iso.macOS -var iso_filename=/Users/Shared/MacOSBigSur.iso.cdr -var iso_file_checksum=none -var headless=true -var boot_wait_iso=180s -var cpu_count=6 -var ram_gb=8  macOS.pkr.hcl
  name = "base"
  sources = [
    "sources.virtualbox-iso.macOS"
  ]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  post-processor "shell-local" {
    inline = [
      "cp ~/VirtualBox\\ VMs/{{build_name}}_${var.macos_version}_base/*.nvram /tmp/{{build_name}}_${var.macos_version}_base.nvram",
      "VBoxManage unregistervm --delete \"{{build_name}}_${var.macos_version}_base\"",
      "cp /tmp/{{build_name}}_${var.macos_version}_base.nvram output/{{build_name}}_${var.macos_version}_base/"
    ]
  }
}

build {
  # manual import:
  # VBoxManage import ./output/macOS_12.0_base/macOS_12.0_base.ovf --vsys 0 --vmname macOS_12.0
  # packer build -force -only=customize.virtualbox-vm.macOS -var headless=true macOS.pkr.hcl
  name    = "customize"
  sources = ["sources.virtualbox-vm.macOS"]

  provisioner "file" {
    sources     = [var.install_bits, "submodules/tccutil/tccutil.py", "files/cliclick"]
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
      "SEEDING_PROGRAM=${var.seeding_program}",
      "XCODE_PATH=~/${var.install_bits}/${var.xcode}",
      "XCODE_CLI_PATH=~/${var.install_bits}/${var.xcode_cli}"
    ]
    scripts = [
      "scripts/xcode.sh",
      "scripts/xcode_cli.sh",
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
