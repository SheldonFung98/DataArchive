# DataArchive
DataArchive allows you to store large dataset files using a github repository and deploy to your target compute server easily.

## usage

### Create a Data Archive
1. Star [this](https://github.com/SheldonFung98/DataArchive) Github repo.
2. Fork [this](https://github.com/SheldonFung98/DataArchive) Github repo.
3. Clone your forked repo.
4. Place your data in the [data](data) folder
5. Use the [archive script](archive.sh) to automatically upload chunked data.
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
