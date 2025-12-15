# Lockfile generation

## Prerequisite

* You must install [https://github.com/konflux-ci/rpm-lockfile-prototype](rpm-lockfile-prototype)

## Input file

The input files for lockfile generation are:

* rpms.in.yaml
* centos-stream-tier1.yaml

## Generating the lockfile

```
rpm-lockfile-prototype rpms.in.yaml
```

or

```
make lockfile
```

## Commit the Result

* The above command will produce the lockfile - **rpms.lock.yaml**
* Commit any changes.

## In a devcontainer

```
make lockfile
```
