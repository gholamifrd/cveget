# cveget
Get publicly available CVEs in grepable (CSV-like) format.
Useful to quickly finding vulnerabilities associated with a specific product.

## Install
```bash
git clone https://github.com/gholamifrd/cveget
cd cveget
chmod +x cveget.sh
./cveget.sh
```

## Usage
```bash

Usage: cveget [-h help|-d days|-c count|-s score|-a all]

    Options:
    -h     Display this help
    -d     Days before now to get CVE data
    -c     Maximum number of results
    -s     Minimum CVSS score
    -a     Get more extensive info about results
```
## Example
find vulnerabilities above 9 for VMware in the past 30 days with maximum results of
1000
```bash
./cveget.sh -d 30 -s 9 -c 1000 | grep "VMware"
```
## Notes
- If ran without arguments, it will use default values(d=10,c=100,s=5)
- `-a` shows some summary about vulnerability along with other info
- Some unnecessary stuff are removed from the results
- Output is TAB separated to be easy on the eyes, to change to csv format:
```bash
./cveget.sh | tr "\t" ","
```
