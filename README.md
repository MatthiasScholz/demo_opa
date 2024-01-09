# Open Policy Agent in Action

This repository provides a basic example how to check
infrastructure creation against given guidelines.


The demo uses [terraform](https://www.terraform.io/) and
[tfswitch](https://tfswitch.warrensbox.com/) and
[AWS](https://aws.amazon.com/de/) as cloud services provider.


[Regula](https://github.com/fugue/regula) and
[Conftest](https://github.com/instrumenta/conftest)
are use to demonstrate the verification making use
of the [Open Policy Agent](https://www.openpolicyagent.org) framework.

Furthermore [aws-vault](https://github.com/99designs/aws-vault)
is used for AWS credential management and the integration
is demonstrated as well.

## Usage

To ease the workflow this repository uses [make](https://www.gnu.org/software/make/).
The demo itself does not depend on make, you can use the [Makefile](Makefile)
to look up the commands and run them on your own.

### Conftest

```bash
make conftest-prepare
make conftest -build-var aws_profile=dev
make cleanup
```

The command assumes a configured AWS profile
in your configuration file [~/.aws/config](~/.aws/config)
with the name `dev`.

### Docker

```bash
make regula-direct
make cleanup
```

### Minimal Dependencies

```bash
# Prepare policies
conftest pull -p policy/ github.com/fugue/regula/conftest
conftest pull -p policy/regula/lib 'github.com/fugue/regula//lib?ref=v0.8.0'
conftest pull -p policy/regula/rules github.com/fugue/regula/rules
# Perform the check
terraform -chdir=example init
terraform -chdir=example plan -refresh=false -out=plan.tfplan
terraform -chdir=example show -json plan.tfplan >plan.json
conftest test plan.json
```

## Prerequisites

As mentioned in the introduction this repository
makes use of several tools. You can use the following
command to help you get settled on MacOSX:

```bash
brew install make
make prerequistes
```

If you want to clean up your system with removing
the used tools, you can run:

```bash
make cleanup-prerequistes
```
