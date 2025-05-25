# DataArchive
DataArchive allows you to store large dataset files using a github repository and deploy to your target compute server easily.

## usage
0. Star [this](https://github.com/SheldonFung98/DataArchive) Github repo.

### Create a Data Archive
1. Create your github repo using [this](https://github.com/SheldonFung98/DataArchive) as template.
2. Clone your own repo.
3. Place your data in the [data](data) folder
4. Use the [archive script](archive.sh) to automatically upload chunked data.
```
./archive.sh upload
```

### Use a Data Archive

1. Clone your forked repo.
2. Use the [archive script](archive.sh).
```
./archive.sh download
```
3. enjoy!

### Tip
When uploading or downloading from a private repo, your GitHub token is needed. You can alternatively save your token to `github.tk` at repo root to advoid token input:
```
your_github_token > github.tk
```