# Description

This resource will download the contents of a specific container in Azure blob
storage to the specified local folder. By default it will check that the
contents of the file match (using the hash value locally and stored in Azure)
but it can also ignore the hashes and just look to download files that are
missing from the local file system instead.
