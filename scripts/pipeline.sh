###This pipeline is aim to remove small RNAs from sequenced samples

#To make it easier to detect mistakes I will add some colors to the echos
# Define color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color


#1. Download the files
 
#First, we will download all the files specified in data/filenames
wget -i data/urls -P data/

#Then, we check if the files are correct
while read url; do
    file_name=$(basename "$url")
    local_file_path="data/${file_name}"
    md5_url="${url}.md5"

    if [ -e "$local_file_path" ]; then
        computed_md5=$(md5sum "$local_file_path" | awk '{print $1}')
        expected_md5=$(curl -sS "$md5_url" | awk '{print $1}')

        if [ "$computed_md5" == "$expected_md5" ]; then
            echo -e "${GREEN}MD5 checksum for $file_name is correct.${NC}"
        else
            echo -e "${RED}MD5 checksum for $file_name is incorrect.${NC}"
        fi
    else
        echo -e "${RED}File $file_name not found.${NC}"
    fi
done < "data/urls"

# Script for download and processing files
contaminants_url="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"

bash scripts/download.sh "$contaminants_url" "res" "yes" "small nuclear"

echo -e "${GREEN}Download and processing completed. Files saved in res.${NC}"

#2. Let's index the contaminant file
#Define the variable contaminants_index

contaminants_index="/home/vant/linuxentregable/decont/res/contaminants_idx"

# Check if the output directory already exists and if not execute it
if [ -e "$contaminants_index" ]; then
    echo -e "${YELLOW}Output directory for contaminants index already exists. Skipping indexing.${NC}"
else
    bash scripts/index.sh "/home/vant/linuxentregable/decont/res/contaminants.fasta" \
        "/home/vant/linuxentregable/decont/res/contaminants_idx"
fi

#3. Merge the samples into a single file
#Define the variables
list_of_samples="/home/vant/linuxentregable/decont/data/*.fastq.gz"
output_directory="/home/vant/linuxentregable/decont/out/merged"

# Create Directories if They Don't Exist
mkdir -p "$output_directory"

for sample_file in $list_of_samples; do
    sample_id=$(basename "$sample_file" | cut -d'_' -f1)
    bash scripts/merge_fastqs.sh "$sample_file" "$output_directory" "$sample_id"
done

echo -e "${GREEN}Files are merged.${NC}"



#As we want to have a record, I will make a new firl called log.out
touch "$log.out"

#Create directorys for log cutadapt and log star
all_log_file="log/log.out"
log_cutadapt="log/cutadapt"
trimmed_directory="out/trimmed"

#4. Cutadapt on the merged files
#First, create directories if they don't exist

mkdir -p "$log_cutadapt"
mkdir -p "$trimmed_directory"



# Now use cutadapt on the files
for merged_file in "$output_directory"/*.fastq.gz; do
    sample_id=$(basename "$merged_file" | cut -d'_' -f1)
    trimmed_file="${trimmed_directory}/${sample_id}_trimmed.fastq.gz"
    log_file="${log_cutadapt}/${sample_id}.log"



#  Check if the output file already exists
    if [ -e "$trimmed_file" ]; then
        echo -e "${YELLOW}Skipping the cutadapt operation as output file for $sample_id already exists.${NC}"
    else
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
            -o "$trimmed_file" "$merged_file" > "$log_file"

		echo -e "${YELLOW}Cutadapt have been performed${NC}"


#Let's store the information on the log file with all the information

       echo "=== Cutadapt Log for $sample_id ===" >> "$all_log_file"
       grep "Reads with adapters" "$log_file" >> "$all_log_file"
       grep "Total basepairs processed" "$log_file" >> "$all_log_file"
    fi
done


#5. Let's do STAR
#Let's assign the variables for STAR
contaminants_index="res/contaminants_idx"
star_output_directory="out/star"


for trimmed_file in "$trimmed_directory"/*.fastq.gz; do
    sample_id=$(basename "$trimmed_file" | cut -d'_' -f1)
    star_output_dir="$star_output_directory/$sample_id"

    # Check if the output directory already exists
    if [ -e "$star_output_dir" ]; then
        echo -e "${YELLOW}Output directory for STAR already exists. Skipping STAR operation for $sample_id${NC}";
    else
        mkdir -p "$star_output_directory/$sample_id" 

        # Run STAR and append relevant information to the temporary log file
        STAR --runThreadN 4 --genomeDir "$contaminants_index" \
            --outReadsUnmapped Fastx --readFilesIn "$trimmed_file" \
            --readFilesCommand gunzip -c --outFileNamePrefix "$star_output_dir/" \
        2>&1 | tee -a "$log_file"

        # Append information from STAR logs to the main log file
        echo -e "${GREEN}=== STAR Log for $sample_id ===${NC}" >> "$all_log_file"
        grep "Uniquely mapped reads %" "$log_file" >> "$all_log_file"
        grep "% of reads mapped to multiple loci" "$log_file" >> "$all_log_file"
        grep "% of reads mapped to too many loci" "$log_file" >> "$all_log_file"
    fi
done

 


