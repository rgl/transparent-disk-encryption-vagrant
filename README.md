A playground for playing with transparent [disk encryption](https://en.wikipedia.org/wiki/Disk_encryption).

# Usage

Build and install the [Ubuntu Base Box](https://github.com/rgl/ubuntu-vagrant).

Install the needed plugins:

```bash
vagrant plugin install vagrant-triggers # see https://github.com/emyl/vagrant-triggers
```

Launch the vagrant environment:

```bash
vagrant up --provider=virtualbox # or --provider=libvirt
```

# Reference

 * [cryptsetup: Frequently Asked Questions](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions)
 * [dm-crypt: Linux kernel device-mapper crypto target](https://gitlab.com/cryptsetup/cryptsetup/wikis/DMCrypt)
 * [dm-crypt/Device encryption (ArchLinux Wiki)](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption)
 * [Disk encryption (ArchLinux Wiki)](https://wiki.archlinux.org/index.php/Disk_encryption)