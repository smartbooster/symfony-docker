# Add gitlab ssh key

We use **ssh** protocol for project clone on gitlab.   
This is documentation for add ssh key on gitlab account. You can found gitlab doc [here](https://docs.gitlab.com/ee/user/ssh.html).

## Generate an SSH key pair

```bash
ssh-keygen -t ed25519 -C "<email>"
```

Press Enter. Output similar to the following is displayed:

```bash
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519):
```

Accept the suggested filename and directory unless want to save in a specific directory.

Specify a passphrase:

_Passphrase is not asked on git clone, so you can fill it_

```bash
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

A public and private key are generated. Next, add the public SSH key to your GitLab account.

## Add an SSH key to your GitLab account

1. Copy your public key to your GitLab account

_require the xclip package (`sudo apt install xclip`)_
```bash
xclip -sel clip < ~/.ssh/id_ed25519.pub
```

Now, public key is on your clipboard.

2. Add to your GitLab account

- Go on gitlab > avatar > Edit profile > SSH Keys > Add new key
- In the Key box, paste the contents of your public key. Must be start with `ssh-ed25519`.
- In the Title box, type a description, like "Work Laptop" or "Home Workstation".
- Select the Usage type `Authentication & Signing`
- Remove Expiration date
- Select `Add key`

## Verify that you can connect

Open a terminal and run this command, replacing `gitlab.example.com` with your GitLab instance URL:

_For retrieve your gitlab instance url : go to see project clone ssh url and take first part before `:` ex : `git@gitlab.com`_

```bash
ssh -T git@gitlab.example.com
```

_If this is the first time you connect, you should verify the authenticity of the [GitLab host](https://docs.gitlab.com/ee/user/gitlab_com/index.html#ssh-host-keys-fingerprints) and re-run the previous command_

You can troubleshoot by running ssh in verbose mode

```bash
ssh -Tvvv git@gitlab.example.com
```