# gh-cleanup-envs

This snippete can be used for cleaning up GitHub environments.

## Prerequirements

### Prepare GitHub PAT

Since the feature implemented with snippets should use GitHub Personal Access Token (PAT),
we need to pass PAT to programs via environmental variables,
because basically PAT, or other confidential information, should not be hard-coded for security reasons.

So, first of all, you need to newly create your PAT with your GitHub Accounts, then store with variables named `TOKEN` to the programs.
Please refer to [GitHub Official documentations](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate PAT.

### Install Poetry

## How to use

```bash
# Set personal access token as environmental variables in your shell
$ export TOKEN='ghp_XXXXXXXXXXXXXXX'

# Provide GitHub username & reponame to determine target URL
$ export GH_USERNAME='hwakabh'
$ export GH_REPONAME='gist'
```
