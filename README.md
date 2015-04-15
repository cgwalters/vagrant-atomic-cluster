Project Atomic (Vagrant style)
------------------------------

Use Vagrant and https://github.com/eparis/kubernetes-ansible to
provision a 3 machine local VM cluster of Project Atomic Hosts.

Getting started: Vagrant installation
-------------------------------------

Install Vagrant on:

 - Fedora: https://fedoraproject.org/wiki/Changes/Vagrant
 - CentOS (coming soon)

Getting started: Initializing this module
-----------------------------------------

    $ git submodule update --init

You will need to do this every time the submodule changes.

Configuring
-----------

Edit `config.yml` to use either `f22` or `centos7`.

Running
-------

    $ vagrant up

will get you the chosen Atomic Host, configured in a Kubernetes
cluster, with a master (hostname `master`) and two nodes (`node-1` and
`node-2).

Updating the box
----------------

    $ atomic host upgrade -r

Destroying and redownloading the latest box
-------------------------------------------

    $ vagrant destroy
    $ vagrant box remove $distro-atomic-host
    $ virsh -c qemu:///system 'vol-delete --pool=default $distro-atomic-host_vagrant_box_image.img'


