#TASK 1

most_common_movie=$(awk -F, '{print $(NF-1), $(NF)}' vodclickstream_uk_movies_03.csv | sort | uniq | awk '{print $1}' | uniq -c | sort -nr | head -n 1) #most common movie
most_common_movie_id=$(echo $most_common_movie | awk '{print $2}') #most common movie id
num_watches=$(echo $most_common_movie | awk '{print $1}') #number of watches

awk -F, -v id="$most_common_movie_id" '$(NF-1) == id {print $4, "has", "'$num_watches'", "unique user watches"; exit}' vodclickstream_uk_movies_03.csv


# TASK 2

# This while loop will store the timestamps in an array
timestamps=()
counter=0
{
  read
  while IFS=, read -r col1 timestamp rest; do
    timestamps+=("$(date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp" +%s)")
    counter=$((counter + 1))
    echo -n "Processed $counter lines\r"
  done
  echo
} < vodclickstream_uk_movies_03.csv


sum_diffs=0

# Loop over the array of timestamps
for ((i=1; i<${#timestamps[@]}; i++)); do
  # Calculate the difference between each pair of subsequent timestamps and add it to the sum of differences
  diff=$((${timestamps[$i]} - ${timestamps[$i-1]}))
  sum_diffs=$(($sum_diffs + $diff))
done

# Calculate the average difference
avg_diff=$(($sum_diffs / (${#timestamps[@]} - 1)))

echo "The average time between subsequent clicks is $avg_diff seconds."

# TASK 3
# This awk script will print the user ID and the total duration of all movies watched by that user
awk -F, '
    {
      user_id = $NF
      duration = $3
      total_duration[user_id] += duration 
      if (total_duration[user_id] > max_duration) {
        max_duration = total_duration[user_id]
        max_user_id = user_id
      }
      print "Processed " NR " lines" > "/dev/stderr"
    }
    END {
      print "User ID: " max_user_id ", Total Duration: " max_duration
    }
  ' vodclickstream_uk_movies_03.csv
