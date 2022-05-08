#!/usr/bin/env bash


# Initialize necessary stuff
function init()
{
if ! command -v jq &> /dev/null; then echo "Please install Jq..."; exit 1;fi
days=10
count=100
score=5
# Calculate correct time fotmat to send to API
time_start=$(date -d "-$days days" +%d-%m-%y)
}

function usage()
{
    echo "Usage: cveget [-h help|-d days|-c count|-s score|-a all]

    Options:
    -h     Display this help
    -d     Days before now to get CVE data
    -c     Maximum number of results
    -s     Minimum CVSS score
    -a     Get more extensive info about results"
}

# Get all CVEs with CVSS scores "$score" and with maximum of "$count" results
function curl_json_data()
{
curl -q "https://cve.circl.lu/api/query" \
	-H "cvss_score: $score" -H "cvss_modifier: above" \
	-H "time_start: $time_start" -H "time_modifier: from" \
	-H "time_type: Published" -H "limit: $count" 2>/dev/null
}

# Extract more extensive fields
function jq_all_fields()
{
jq -r '[.results[] | {id: (.id), cvss: (.cvss), cwe: (.cwe),
    company: (.vulnerable_configuration[0] // "-"|split(":")[3]),
    product: (.vulnerable_configuration[0] // "-"|split(":")[4]),
    reference: (.references[0]), summary: (.summary),
    vector: (.access.vector)}]' 2>/dev/null
}

# Extract interesting fields
function jq_important_fields()
{
jq -r '[.results[] | {id: (.id), cvss: (.cvss), cwe: (.cwe),
    company: (.vulnerable_configuration[0] // "-"|split(":")[3]),
    product: (.vulnerable_configuration[0] // "-"|split(":")[4])}]' 2>/dev/null
}

# Make output grepable
function make_csv()
{
jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' 2>/dev/null
}

# Use above helper functions to get important results
function get_importants()
{
    curl_json_data | jq_important_fields | make_csv | sed 's/"//g; s/,/\t/g'
}

# Use above helper functions to get all(extensive) results
function get_all()
{
    curl_json_data | jq_all_fields | make_csv | sed 's/"//g; s/,/\t/g'
}

function main()
{
    init
    if [ $# -eq 0 ]
    then
        get_importants
    elif [[ "$@" != *"-"* ]]
    then
        usage; exit 0
    else
        # Parse arguments
        while getopts "had:c:s:" opt; do
            case $opt in
                \?)
                    usage; exit 0
                    ;;
                h)
                    usage; exit 0
                    ;;
                d)
                    days=${OPTARG}
                    # Calculate correct time fotmat to send to API
                    time_start=$(date -d "-$days days" +%d-%m-%y)
                    ;;
                c)
                    count=${OPTARG}
                    ;;
                s)
                    score=${OPTARG}
                    ;;
                a)
                    get_all
                    exit 0
                    ;;
                :)
                    usage; exit 0
                    ;;
                *)
                    usage; exit 0
                    ;;
            esac
        done
        get_importants
    fi
}

main "$@"
