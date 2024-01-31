##This script is for cleanup and remove files or directories
#1. Function to remove a directory if it exists
cleanup_directory() {
    if [ -d "$1" ]; then
        echo "Removing $1"
        rm -r "$1"
    fi
}

# Check if no arguments are provided, remove everything
if [ "$#" -eq 0 ]; then
    echo "Removing all directories: data, resources, output, logs"
    cleanup_directory "data"
    cleanup_directory "resources"
    cleanup_directory "output"
    cleanup_directory "logs"
else
    # Loop through the provided arguments and remove corresponding directories
    for arg in "$@"; do
        case "$arg" in
            "data"|"res"|"out"|"logs")
                cleanup_directory "$(/bin/echo -n $arg)"
                ;;
            *)
                echo "Invalid argument: $arg. Valid arguments are: data, res, out, logs"
                ;;
        esac
    done
fi
