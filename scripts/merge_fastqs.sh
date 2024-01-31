# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

samples_directory="$(realpath "$1")"
output_directory="$(realpath "$2")"
sample_id="$3"


#Define colors to check easier the process
YELLOW='\033[1;33m'
NC='\033[0m'  

mkdir -p "$output_directory"

# Change to the samples directory
cd "$(dirname "$samples_directory")" || exit


# Merge all files for the specified sample ID into a single file
cat "${sample_id}"*.1.1s_sRNA.fastq.gz "${sample_id}"*.1.2s_sRNA.fastq.gz > "$output_directory"/"${sample_id}"_merged.fastq.gz


echo -e "${YELLOW}Merge completed. Merged file saved in '$output_directory'.${NC}"





