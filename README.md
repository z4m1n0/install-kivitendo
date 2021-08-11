# Work in progress

At the moment only ./install_and_setup_kivitendo_on_arch.sh is tested. If you
find bugs or want to add more distros don't hesitate to open issues or pull
requests.

# install-kivitendo
Installation-Script for Kivitendo

These installation and setup scripts are for developers or administrators, who
want a working Kivitendo-Erp installation in a short time. Kivitendo-Crm can
optically be installed.

# Use in terminal

Clone this repository:

    git clone https://github.com/z4m1n0/install-kivitendo.git
    cd install-kivtendo

Change to root without setting environment variables ('$USER' is needed):

    su

Run the `install_and_setup_kivitendo_on_XXXXX.sh` script for your distro. Where
`XXXXX` stands for your distro.\
For example if you use archlinux:

    ./install_and_setup_kivitendo_on_arch.sh

If you have already all dependencies for Kivitendo installed then you can just
run `install_and_setup_kivitendo_for_apache2.sh` or
`install_and_setup_kivitendo_for_httpd.sh`, depending on your apache
installation. You can check all dependencies whith running
`./scripts/installation_check.pl --all` in the git-repository folder
kivitendo-erp.

    ./install_and_setup_kivitendo_for_apache2.sh.sh

<details>
<summary>Setup scripts</summary>

| script                                | usage                                        | description                                |
|---------------------------------------|----------------------------------------------|--------------------------------------------|
| `setup_kivitendo.sh`                  | `-p passwd -d install_dir`                   | setup kivitendo forlders and create config |
| `setup_postgresql.sh`                 | `-p passwd -d install_dir [-D postgres_dir]` | change psql config and setup users         |
| `setup_httpd.sh` / `setup_apache2.sh` | `-d install_dir`                             | change apache config and creates vhosts    |

</details>

