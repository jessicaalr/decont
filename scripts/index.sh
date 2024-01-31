# First, I will assign the variables
genome_file="$1"
output_directory="$2"
gunzip_option="$3"

#Define color to check the process
GREEN='\033[0;32m'
NC='\033[0m' 

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

#Check if is needed to decompress
if [ "$gunzip_option" = "yes" ]; then
    gunzip -k "$output_directory/filename.gz"
    filename="${output_directory}/filename"
else
    filename="$genome_file"
fi

# STAR command to generate genome index
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$output_directory" \
    --genomeFastaFiles "$genome_file" --genomeSAindexNbases 9

echo -e "${GREEN}Genome indexing completed successfully.${NC}"


# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).


