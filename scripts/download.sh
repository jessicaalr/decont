#Script for download the files


#First, define the variables

download_url="$1"
output_directory="$2"
uncompress="$3"
keywords="$4"

#I am going to put colors to the echos to make it easier to detect potential errors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Download the file
wget "$download_url" -P "$output_directory"


echo -e "${GREEN}Downloading files from: ${download_url}${NC}"
echo -e "${GREEN}Saving files to: ${output_directory}${NC}"


for filepath in "$output_directory"/*; do
    # Check if uncompress flag is set to "yes"
    if [ "$uncompress" == "yes" ]; then
        gunzip "$filepath"
        filepath="${filepath%.gz}"  
    fi

#Filtering

# Check if exclude keyword is given
    if [ -n "$keywords" ]; then
    	grep -v "$keywords" "$filepath" > "$output_directory/filtered_$(basename "$filepath")"
    	mv "$output_directory/filtered_$(basename "$filepath")" "$filepath"
    fi

done


echo -e "${GREEN}Download and processing completed. Files saved in: ${output_directory}${NC}"







# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
