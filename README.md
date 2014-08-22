Vagrant + Puppet sandbox example
=================================

This repo is intended to server as a demonstration of using
[Vagrant](https://www.vagrantup.com/) with [Puppet](http://puppetlabs.com/) to
construct a virtual machine 'sandbox' for testing.  There are many valuable benefits from this approach, which include:

* a clean testing environment free of side-effects or state entropy caused by other packages
* re-produciblity of the testing env
* the ability to validate system level changes that may be destructive

Vagrant has the ability to use a
[provisioning](https://docs.vagrantup.com/v2/provisioning/index.html) tool to
automatically apply changes to a Vagrant 'box' upon startup.

This demo requires that several tools are available on your system:

* VirtualBox (used by Vagrant)
* Vagrant 1.4.x
* Ruby 1.9.3 or greater
* the Ruby `bundler` gem
* `git` - needed to clone this repo

VirtualBox Install
------------------

VirtualBox is a hypervisor originally created at Sun Microsystems and is now a
product of Oracle.  It provides a GUI virtual machine manager and is supported
on several platforms including OSX and Linux.  It is probably the most popular
Vagrant hypervisor target by a wide margin.

Packages are available from the [Download Virtual](Box https://www.virtualbox.org/wiki/Downloads) page.

### EL6.x

The RPM packages depend on a number of other packages, so it is recommended that you install virtualbox with `yum` instead of `rpm` directly, as it will likely failed do to unresolved dependencies.

    sudo yum install -y http://download.virtualbox.org/virtualbox/4.3.14/VirtualBox-4.3-4.3.14_95030_el6-1.x86_64.rpm

Snippet of `yum` output:

```
================================================================================
 Package                  Arch   Version            Repository             Size
================================================================================
Installing:
 VirtualBox-4.3           x86_64 4.3.14_95030_el6-1 /VirtualBox-4.3-4.3.14_95030_el6-1.x86_64
                                                                          150 M
Installing for dependencies:
 SDL                      x86_64 1.2.14-3.el6       base                  193 k
 cdparanoia-libs          x86_64 10.2-5.1.el6       base                   47 k
 gstreamer                x86_64 0.10.29-1.el6      base                  764 k
 gstreamer-plugins-base   x86_64 0.10.29-2.el6      base                  940 k
 gstreamer-tools          x86_64 0.10.29-1.el6      base                   23 k
 iso-codes                noarch 3.16-2.el6         base                  2.4 M
 lcms-libs                x86_64 1.19-1.el6         base                  100 k
 libICE                   x86_64 1.0.6-1.el6        base                   53 k
 libSM                    x86_64 1.2.1-2.el6        base                   37 k
 libXmu                   x86_64 1.1.1-2.el6        base                   66 k
 libXt                    x86_64 1.1.3-1.el6        base                  184 k
 libXv                    x86_64 1.0.7-2.el6        base                   24 k
 libXxf86vm               x86_64 1.1.2-2.el6        base                   22 k
 libgudev1                x86_64 147-2.51.el6       base                   61 k
 libmng                   x86_64 1.0.10-4.1.el6     base                  165 k
 libogg                   x86_64 2:1.1.4-2.1.el6    base                   21 k
 liboil                   x86_64 0.3.16-4.1.el6     base                  121 k
 libtheora                x86_64 1:1.1.0-2.el6      base                  129 k
 libvisual                x86_64 0.4.0-9.1.el6      base                  135 k
 libvorbis                x86_64 1:1.2.3-4.el6_2.1  base                  168 k
 mesa-dri-drivers         x86_64 9.2-0.5.el6_5.2    updates               6.1 M
 mesa-dri-filesystem      x86_64 9.2-0.5.el6_5.2    updates                15 k
 mesa-dri1-drivers        x86_64 7.11-8.el6         base                  3.8 M
 mesa-libGL               x86_64 9.2-0.5.el6_5.2    updates               110 k
 mesa-libGLU              x86_64 9.2-0.5.el6_5.2    updates               196 k
 mesa-private-llvm        x86_64 3.3-0.3.rc3.el6    base                  5.3 M
 phonon-backend-gstreamer x86_64 1:4.6.2-28.el6_5   updates               127 k
 qt                       x86_64 1:4.6.2-28.el6_5   updates               3.9 M
 qt-sqlite                x86_64 1:4.6.2-28.el6_5   updates                51 k
 qt-x11                   x86_64 1:4.6.2-28.el6_5   updates                12 M
 xml-common               noarch 0.6.3-32.el6       base                  9.5 k

Transaction Summary
================================================================================
Install      32 Package(s)

Total size: 188 M
Total download size: 37 M
Installed size: 271 M
```

Sanity check that the VirtualBox kernel modules are loaded.

```
$ sudo service vboxdrv status
VirtualBox kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci) are loaded.
```

Note - The Fedora 19 RPMs are known to be compatible with Fedora 20.

Vagrant Install
---------------

Vagrant is a tool to automate the setup of one or more virtual machines based on pre-created VM images.  It has the nice feature of being able to download images, also called Vagrant "boxes", based on URl.

I recommend for the moment staying with a 1.4.x release, although the current stable series is 1.6.x.

https://www.vagrantup.com/downloads.html

### EL6.x

    sudo yum install -y https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.rpm

Vagrant is a heavily "vendored" package.  Snippet from `yum` output:

```
================================================================================
 Package       Arch         Version           Repository                   Size
================================================================================
Installing:
 vagrant       x86_64       1:1.4.3-1         /vagrant_1.4.3_x86_64        53 M

Transaction Summary
================================================================================
Install       1 Package(s)

```

### `cachier` plugin

[`cachier`](https://github.com/fgrehm/vagrant-cachier) is plugin for Vagrant
that does some magic to cache package downloads.  It's a great time/bandwidth
saver if your repeatedly starting up the same Vagrant box and installing
packages.  It is not required for this demo -- merely recommended for general usage.


    vagrant plugin install vagrant-cachier

```
Installing the 'vagrant-cachier' plugin. This can take a few minutes...
Installed the plugin 'vagrant-cachier (0.9.0)'!
Post install message from the 'vagrant-cachier' plugin:


  Thanks for installing vagrant-cachier 0.9.0!

  If you are new to vagrant-cachier just follow along with the docs available
  at http://fgrehm.viewdocs.io/vagrant-cachier.

  If you are upgrading from a previous version, please note that plugin has gone
  through many backwards incompatible changes recently. Please check out
  https://github.com/fgrehm/vagrant-cachier/blob/master/CHANGELOG.md
  before continuing and caching all the things :)

```

Ruby Install
------------

Ruby is needed by this demo for the tool that's used to fetch puppet modules.
While the system version of Ruby can be used for this, I highly recommend
making a user level install using `rvm` or `rbenv` so that per app dependencies
don't pollute the system installation.

### `rvm`

    \curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
    source ~/.rvm/scripts/rvm
    rvm use 1.9.3

There will likely be a warning similar to below about 1.9.3 being unmaintained,
you can ignore it for the time being.

```
WARNING: Please be aware that you just installed a ruby that is no longer maintained (2014-02-23), for a list of maintained rubies visit:

    http://bugs.ruby-lang.org/projects/ruby/wiki/ReleaseEngineering

Please consider upgrading to ruby-2.1.2 which will have all of the latest security patches.

```

Sanity check:

    ruby --version

```
$ ruby --version
ruby 1.9.3p547 (2014-05-14 revision 45962) [x86_64-linux]
```

Demo Setup
----------

A `bundler` `Gemfile` is provided for automatic Ruby `gem` installation.  The
tool this demo uses for fetching puppet modules is called `librarian-puppet`
and it is distributed as a `gem`.

### clone this repo


    git clone https://github.com/jhoblitt/sandbox-puppet-mdadm.git

```
$ git clone https://github.com/jhoblitt/sandbox-puppet-mdadm.git
Initialized empty Git repository in /home/vagrant/sandbox-puppet-mdadm/.git/
remote: Counting objects: 8, done.
remote: Total 8 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (8/8), done.

```

### change pwd

    cd sandbox-puppet-mdadm

### run Bundler

    bundle install

```
$ bundle install
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Installing CFPropertyList 2.2.8
Installing i18n 0.6.11
Installing json 1.8.1
Installing minitest 5.4.0
Installing thread_safe 0.3.4
Installing tzinfo 1.2.2
Installing activesupport 4.1.5
Installing builder 3.2.2
Installing activemodel 4.1.5
Installing facter 2.1.0
Installing multipart-post 2.0.0
Installing faraday 0.9.0
Installing multi_json 1.10.1
Installing her 0.7.2
Installing json_pure 1.8.1
Installing hiera 1.3.4
Installing highline 1.6.21
Installing thor 0.19.1
Installing librarian 0.1.2
Installing puppet_forge 1.0.3
Installing librarian-puppet 1.3.2
Installing rgen 0.6.6
Installing puppet 3.6.2
Using bundler 1.7.0
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

### run `librarian-puppet`

    bundle exec librarian-puppet install

```
$ bundle exec librarian-puppet install
$ echo $?
0
```

Running the Demo
----------------

    vagrant up

```
[vagrant@localhost sandbox-puppet-mdadm]$ vagrant up
Bringing machine 'centos' up with 'virtualbox' provider...
[centos] Box 'centos65' was not found. Fetching box from specified URL for
the provider 'virtualbox'. Note that if the URL does not have
a box for this provider, you should interrupt Vagrant now and add
the box yourself. Otherwise Vagrant will attempt to download the
full box prior to discovering this error.
Downloading box from URL: http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box
Extracting box...te: 4562k/s, Estimated time remaining: --:--:--)
Successfully added box 'centos65' with provider 'virtualbox'!
[centos] Importing base box 'centos65'...
[centos] Matching MAC address for NAT networking...
[centos] Setting the name of the VM...
[centos] Clearing any previously set forwarded ports...
[centos] Clearing any previously set network interfaces...
[centos] Preparing network interfaces based on configuration...
[centos] Forwarding ports...
[centos] -- 22 => 2222 (adapter 1)
[centos] Running 'pre-boot' VM customizations...
[centos] Booting VM...
[centos] Waiting for machine to boot. This may take a few minutes...
[centos] Machine booted and ready!
[centos] The guest additions on this VM do not match the installed version of
VirtualBox! In most cases this is fine, but in rare cases it can
prevent things such as shared folders from working properly. If you see
shared folder errors, please make sure the guest additions within the
virtual machine match the version of VirtualBox you have installed on
your host and reload your VM.

Guest Additions Version: 4.3.6
VirtualBox Version: 4.2
[centos] Mounting shared folders...
[centos] -- /vagrant
[centos] -- /tmp/vagrant-cache
[centos] -- /tmp/vagrant-puppet-1/manifests
[centos] -- /tmp/vagrant-puppet-1/modules-0
[centos] Running provisioner: shell...
[centos] Configuring cache buckets...
[centos] Running: inline script
Warning: The resulting partition is not properly aligned for best performance.
Warning: The resulting partition is not properly aligned for best performance.
mdadm: array /dev/md0 started.
[centos] Running provisioner: puppet...
[centos] Configuring cache buckets...
Running Puppet with init.pp...
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/puppet_vardir.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/facter_dot_d.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/root_home.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/pe_version.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadm_arrays.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadmversion.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadm.rb
Warning: Could not retrieve fact fqdn
Warning: Config file /etc/puppet/hiera.yaml not found, using Hiera defaults
Notice: Compiled catalog for localhost in environment production in 1.71 seconds
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/puppet_vardir.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/facter_dot_d.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/root_home.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/stdlib/lib/facter/pe_version.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadm_arrays.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadmversion.rb
Info: Loading facts in /tmp/vagrant-puppet-1/modules-0/mdadm/lib/facter/mdadm.rb
Info: Applying configuration version '1408750632'
Notice: Augeas[mdadm.conf mailaddr](provider=augeas): 
--- /etc/mdadm.conf 2014-08-22 16:37:05.867187490 -0700
+++ /etc/mdadm.conf.augnew  2014-08-22 16:37:17.175838980 -0700
@@ -1 +1,2 @@
 ARRAY /dev/md0 metadata=0.90 UUID=e4cf300a:7b815abe:bfe78010:bc810f04
+MAILADDR root

Notice: /Stage[main]/Mdadm::Config/Augeas[mdadm.conf mailaddr]/returns: executed successfully
Notice: /Stage[main]/Mdadm::Mdmonitor/Service[mdmonitor]/ensure: ensure changed 'stopped' to 'running'
Info: /Stage[main]/Mdadm::Mdmonitor/Service[mdmonitor]: Unscheduling refresh on Service[mdmonitor]
Notice: /Stage[main]/Augeas::Packages/Package[augeas]/ensure: created
Notice: /Stage[main]/Augeas::Files/File[/usr/share/augeas/lenses/tests]/ensure: created
Notice: /Stage[main]/Mdadm::Raid_check/File[/etc/sysconfig/raid-check]/content: 
--- /etc/sysconfig/raid-check   2013-10-11 07:13:08.000000000 -0700
+++ /tmp/puppet-file20140822-3952-1fc05v8-0 2014-08-22 16:38:03.911194937 -0700
@@ -46,11 +46,19 @@
 # /dev/md/root.  The names used in this file must match the names seen in
 # /proc/mdstat and in /sys/block.
 
-ENABLED=yes
-CHECK=check
-NICE=low
+# ENABLED=yes
+# CHECK=check
+# NICE=low
 # To check devs /dev/md0 and /dev/md3, use "md0 md3"
+# CHECK_DEVS=""
+# REPAIR_DEVS=""
+# SKIP_DEVS=""
+# MAXCONCURRENT=
+
+CHECK="check"
 CHECK_DEVS=""
+ENABLED="yes"
+MAXCONCURRENT=""
+NICE="low"
 REPAIR_DEVS=""
 SKIP_DEVS=""
-MAXCONCURRENT=

Info: /Stage[main]/Mdadm::Raid_check/File[/etc/sysconfig/raid-check]: Filebucketed /etc/sysconfig/raid-check to puppet with sum 048bfb96ded93b95612dd072e5d77617
Notice: /Stage[main]/Mdadm::Raid_check/File[/etc/sysconfig/raid-check]/content: content changed '{md5}048bfb96ded93b95612dd072e5d77617' to '{md5}1784486325d4997d427c0c2a548360f9'
Info: Creating state file /var/lib/puppet/state/state.yaml
Notice: Finished catalog run in 48.22 seconds
[centos] Configuring cache buckets...

```

Working with Vagrant
--------------------

Vagrant is a very powerful tool with a multitude of CLI options.  Skimming the [CLI docs](https://docs.vagrantup.com/v2/cli/index.html) is recommended.

A few common commands are:

### up

Create/start up a box.  This will also run the provisioner defined in the `Vagrantfile` if it has not already been run once.

    vagrant up

```
$ vagrant up
Bringing machine 'centos' up with 'virtualbox' provider...
[centos] Clearing any previously set forwarded ports...
[centos] Fixed port collision for 22 => 2222. Now on port 2200.
[centos] Clearing any previously set network interfaces...
[centos] Preparing network interfaces based on configuration...
[centos] Forwarding ports...
[centos] -- 22 => 2200 (adapter 1)
[centos] Running 'pre-boot' VM customizations...
[centos] Booting VM...
[centos] Waiting for machine to boot. This may take a few minutes...
[centos] Machine booted and ready!
[centos] The guest additions on this VM do not match the installed version of
VirtualBox! In most cases this is fine, but in rare cases it can
prevent things such as shared folders from working properly. If you see
shared folder errors, please make sure the guest additions within the
virtual machine match the version of VirtualBox you have installed on
your host and reload your VM.

Guest Additions Version: 4.3.6
VirtualBox Version: 4.2
[centos] Mounting shared folders...
[centos] -- /vagrant
[centos] -- /tmp/vagrant-cache
[centos] -- /tmp/vagrant-puppet-1/manifests
[centos] -- /tmp/vagrant-puppet-1/modules-0
[centos] VM already provisioned. Run `vagrant provision` or use `--provision` to force it
```
### ssh

Connect to a running box.

    vagrant ssh

```
$ vagrant ssh
Last login: Thu Jan 16 09:37:38 2014 from 10.0.2.2
Welcome to your Packer-built virtual machine.
```

### destroy

Stop a running box and/or destroy the image.

    vagrant destroy

```
$ vagrant destroy
Are you sure you want to destroy the 'centos' VM? [y/N] y
[centos] Forcing shutdown of VM...
[centos] Destroying VM and associated drives...
[centos] Running cleanup tasks for 'shell' provisioner...
[centos] Running cleanup tasks for 'puppet' provisioner...
```

### provision

    vagrant provision

```
$ vagrant provision
[centos] Running provisioner: shell...
[centos] Configuring cache buckets...
[centos] Running: inline script
[centos] Running provisioner: puppet...
[centos] Configuring cache buckets...
...
Running Puppet with init.pp...
...
```

Provisioner Details
-------------------
