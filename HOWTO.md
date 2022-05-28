Hosting own Debian APT repository on GitHub
===========================================

May 28, 2022 • Kirubakaran Shanmugam

### Repository format
```
ppa
├── dists
│   └── stable
│       ├── InRelease
│       ├── main
│       │   ├── binary-aarch64
│       │   │   ├── Packages
│       │   │   └── Packages.gz
│       │   └── binary-amd64
│       │       ├── Packages
│       │       └── Packages.gz
│       ├── Release
│       └── Release.gpg
└── pool
    └── main
        ├── kplay
        │   └── kplay_1.0-0_amd64.deb
        ├── kstat
        │   ├── kstat_1.0-0_amd64.deb
        │   └── kstat_1.0_aarch64.deb
        └── ktools
            ├── ktools_1.0-a_aarch64.deb
            └── ktools_1.0-a_amd64.deb
```
You can name the repository `ppa` or whatever you like.

### 0\. Creating a GitHub repository and GitHub Pages

- [Create a GitHub repo](https://github.com/new) with name `ppa`
- Create GitHub Page: Visit `https://github.com/${GITHUB_USERNAME}/ppa/settings/pages`
- Under `GitHub Pages` select `Source` to be `master branch`.

Any HTTP server will work fine, but the GitHub page is free to use.

Now clone the repo and put your debian packages inside `ppa/pool/main/${PKGDIR}/${PKGNAME}.deb`.
```
    git clone git@github.com:atomixcloud/ppa.git
    cd ppa
    cp PACKAGE.deb pool/main/kstat/
```
### 1\. Creating a GPG key

Install `gpg` and create a new key:

    sudo apt install gnupg
    gpg --full-gen-key
    

Use RSA:

    Please select what kind of key you want:
       (1) RSA and RSA (default)
       (2) DSA and Elgamal
       (3) DSA (sign only)
       (4) RSA (sign only)
    Your selection? 1
    

RSA with 4096 bits:

    RSA keys may be between 1024 and 4096 bits long.
    What keysize do you want? (3072) 4096
    

Key should be valid forever:

    Please specify how long the key should be valid.
    0 = key does not expire
    <n> = key expires in n days
    <n>w = key expires in n weeks
    <n>m = key expires in n months
    <n>y = key expires in n years
    Key is valid for? (0) 0
    Key does not expire at all
    Is this correct? (y/N) y
    

Enter your name and email:

    Real name: Full Name
    Email address: ${DEBEMAIL}
    Comment:
    You selected this USER-ID:
    "Full Name <[email]>"
    
    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
    

At this point the `gpg` command will start to create your key and will ask for a passphrase for extra protection. I like to leave it blank so when I sign things with my key it won’t promp for the passphrase each time.

    We need to generate a lot of random bytes. It is a good idea to perform
    some other action (type on the keyboard, move the mouse, utilize the
    disks) during the prime generation; this gives the random number
    generator a better chance to gain enough entropy.
    We need to generate a lot of random bytes. It is a good idea to perform
    some other action (type on the keyboard, move the mouse, utilize the
    disks) during the prime generation; this gives the random number
    generator a better chance to gain enough entropy.
    gpg: key B58FBB4C23247554 marked as ultimately trusted
    gpg: directory '/home/assafmo/.gnupg/openpgp-revocs.d' created
    gpg: revocation certificate stored as '/home/assafmo/.gnupg/openpgp-revocs.d/31EE74534094184D9964EF82B58FBB4C23247554.rev'
    public and secret key created and signed.
    
    pub rsa4096 2019-05-01 [SC]
    31EE74534094184D9964EF82B58FBB4C23247554
    uid My Name <[email protected]>
    sub rsa4096 2019-05-01 [E]
    

You can backup your private key using:

    gpg --export-secret-keys "${DEBEMAIL}" > private-key.asc
    

And import it using:

    gpg --import private-key.asc
    

### 2\. Creating the `KEY.gpg` file

Create the ASCII public key file `KEY.gpg` inside the git repo `ppa`:

    gpg --armor --export "${DEBEMAIL}" > key.gpg
    

Note: The private key is referenced by the email address you entered in the previous step.

### 3\. Creating the `Packages` and `Packages.gz` files

Inside the git repo `ppa`:

    dpkg-scanpackages --multiversion . > Packages
    gzip -k -f Packages
    

### 4\. Creating the `Release`, `Release.gpg` and `InRelease` files

Inside the git repo `ppa`:

    apt-ftparchive release . > Release
    gpg --default-key "${DEBEMAIL}" -abs -o - Release > Release.gpg
    gpg --default-key "${DEBEMAIL}" --clearsign -o - Release > InRelease
    

### 5\. Creating the `Packages.list` file

Inside the git repo `ppa`:

    echo "deb https://${GITHUB_USERNAME}.github.io/ppa ./" > Packages.list
    

This file will be installed later on in the user’s `/etc/apt/sources.list.d/` directory. This tells `apt` to look for updates from your PPA in `https://${GITHUB_USERNAME}.github.io/ppa`.

### That’s it!

Commit and push to GitHub and your PPA is ready to go:

    git add -A
    git commit -m "Initial commit"
    git push -u origin master
    

Now you can tell all your friends and users to install your PPA this way:

    curl -s --compressed "https://${GITHUB_USERNAME}.github.io/ppa/KEY.gpg" | sudo apt-key add -
    sudo curl -s --compressed -o /etc/apt/sources.list.d/Packages.list "https://${GITHUB_USERNAME}.github.io/ppa/Packages.list"
    sudo apt update

Then they can install your packages:

    sudo apt install package-a package-b package-z
    

Whenever you publish a new version for an existing package your users will get it just like any other update.

### How to add new packages

Just put your new `.deb` files inside the git repo `ppa` and execute:

    # Packages & Packages.gz
    dpkg-scanpackages --multiversion . > Packages
    gzip -k -f Packages
    
    # Release, Release.gpg & InRelease
    apt-ftparchive release . > Release
    gpg --default-key "${DEBEMAIL}" -abs -o - Release > Release.gpg
    gpg --default-key "${DEBEMAIL}" --clearsign -o - Release > InRelease
    
    # Commit & push
    git add -A
    git commit -m update
    git push

### End of document

