# 🔏🍟 Fritoto: The *Friday-or-not* Attestationator

__Stop deployments built on Fridays!__

We all know it: You don't deploy on a Friday, right?
Good news! 🎉 Now, with `fritoto` you can generate an
attestation to prevent friday builds from ever deploying.

Fritoto defines a next-generation predicate that captures
in digitally signed envelope the required data to know if
that binary or container is Fridat free.

## Disclaimer 😇

This project works, but it's a joke. It is intended to
demonstrate a project protected end to end with
[SLSA](https://slsa.dev) (Supply-chain Levels for Software Artifacts).

That said, feel free to use it to protect your weekend from
Friday sourced artifacts.

## Usage

To generate a `built-on-friday/v1` attestaion to describe the _fridayness_
of your builds, simply download the latest binary and feed it your
artifacts:

```bash
fritoto file1.exe file2.dmg...
```
Here's the `--help` output from the binary

```
     _               
   _|_._o_|_ __|_ _  
    | | | |_(_)|_(_) 

   🔏🍟 fritoto — the *Friday-or-not* attestationator

Usage:
  fritoto [flags] file [file...]

Flags:
  -h, --help              help for fritoto
      --notes string      Optional note to include in the predicate
  -o, --out string        Output file for attestation (default: stdout)
  -s, --subject strings   Paths to subject files to attest (required)
      --time string       Build time to attest (default "2025-09-26T19:49:05-06:00")
```

## Sample Attestation

Here is a sample attestation with a `v1` predicate:

```json
{
  "predicateType": "https://carabiner.dev/built-on-friday/v1",
  "predicate": {
    "builtOnFriday": true,
    "buildTime": "2025-09-26T20:04:53-06:00"
  },
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    {
      "name": "application.exe",
      "digest": {
        "sha256": "e5170bd239a37712e40cacc2d0645211a290661c6e786130f68a3efb0ccd77b4",
        "sha512": "94263557ea2f9a4b98cc7512e2a5816e62f3dc5e4632d584f80a096aea19b2ba02b8d5f57ade41127e07f4ae122bbd066b6dfe9ab55d9fae2b76468a758dc354"
      }
    }
  ]
}
```

## Contributions... 

Welcome but maybe no needed?

This repository is a silly joke to demonstrate how SLSA can protect
a project. This means that we are not really trying to improve but
if you feel so inclined, send patches. The code is Copyright by
Carabiner Systems, Inc and is released under the Apache-2.0 licence.
