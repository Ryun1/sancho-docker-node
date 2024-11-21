#!/bin/bash

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Function to display script usage
usage() {
  echo "Usage: $0 <ga_id>"
  echo "Example: $0 66cbbf693a8549d0abb1b5219f1127f8176a4052ef774c11a52ff18ad1845102#0"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

ga_id="$1"

# Extract ga_hash and ga_index from ga_id
ga_hash=$(echo "$ga_id" | cut -d '#' -f 1)
ga_index=$(echo "$ga_id" | cut -d '#' -f 2)

proposal=$(container_cli conway query gov-state | jq '.proposals[] | select(.actionId.txId == "$ga_hash")')
stakeDistribution=$(container_cli conway query drep-stake-distribution --all-dreps)
stakeDistributionCorrected=$(echo "$stakeDistribution" | jq 'map(.[0] |= sub("drep-"; ""))')
dRepVotes=$(echo "$proposal" | jq -r '.dRepVotes')
alwaysAbstain=$(echo "$stakeDistributionCorrected" | jq '.[] | select(.[0] == "alwaysAbstain") | .[1]' )
alwaysNoConf=$(echo "$stakeDistributionCorrected" | jq '.[] | select(.[0] == "alwaysNoConfidence") | .[1]' )
totalStake=$(echo "$stakeDistribution" | jq '[.[] | select(.[1] | type == "number")] | map(.[1]) | add')

# Initialize counters for VoteYes, VoteNo, and VoteAbstain
yesCount=0
noCount=0
abstainCount=0

# Loop through each key-value pair in dRepVotes
while IFS="=" read -r registry vote; do
    # Remove leading and trailing whitespace from registry and vote
    registry=$(echo "$registry" | tr -d '[:space:]')
    vote=$(echo "$vote" | tr -d '[:space:]')
    # Extract the corresponding stake from stakeDistributionCorrected
    stake=$(echo "$stakeDistributionCorrected" | jq --arg registry "$registry" '.[] | select(.[0] == $registry) | .[1]')
    # Update the counter based on the direction of the vote
    case $vote in
        "VoteYes")
            yesCount=$((yesCount + stake))
            ;;
        "VoteNo")
            noCount=$((noCount + stake))
            ;;
        "Abstain")
            abstainCount=$((abstainCount + stake))
            ;;
    esac
    echo "Registry: \"$registry\""
    echo "Vote: $vote"
    echo "Stake: $stake"
done <<< "$(echo "$dRepVotes" | jq -r 'to_entries[] | "\(.key)=\(.value)"')"

totalNo=$(($noCount + $alwaysNoConf))
totalAbstain=$(($abstainCount + $alwaysAbstain))
totalMinusAbstain=$(("$totalStake" - "$totalAbstain"))
ratio=$(echo "scale=6; $yesCount / $totalMinusAbstain" | bc)
threshold=0.67


# Output the results
echo " "
echo "Total stake: $totalStake"
echo "Total VoteYes: $yesCount"
echo "Total VoteNo: $noCount"
echo "Total VoteNo + AlwaysNoConf: $totalNo"  
echo "Total Abstain: $abstainCount"
echo "Total AlwaysAbstian: $alwaysAbstain"
echo "TotalStake - AlwaysAbstain - VoteAbstain: $totalMinusAbstain" 
echo "Ratio vs threshold: $ratio vs $threshold"


stakeKeys=$(echo "$stakeDistributionCorrected" | jq -r 'map(.[0]) | map(select(. != "alwaysAbstain" and . != "alwaysNoConfidence"))[]')


# Initialize an associative array to store DRep keys and their associated stake
declare -A notVotedDReps

# Loop through each DRep key from stakeKeys
for key in $stakeKeys; do
    # Check if the DRep key has not voted yet
    if ! echo "$dRepVotes" | jq -e --arg key "$key" 'has($key)' &> /dev/null; then
        # If the DRep has not voted yet, extract its stake from stakeDistributionCorrected
        stake=$(echo "$stakeDistributionCorrected" | jq --arg key "$key" '.[] | select(.[0] == $key) | .[1]')
        # Store the DRep key and its associated stake in the notVotedDReps associative array
        notVotedDReps["$key"]=$stake
    fi
done

# Sort notVotedDReps by stake in descending order
sortedNotVotedKeys=($(for key in "${!notVotedDReps[@]}"; do echo "$key ${notVotedDReps[$key]}"; done | sort -rnk2,2 | awk '{print $1}'))

# Output DReps that have not voted yet, along with their associated stake (sorted by stake, larger to smaller)
echo "DReps that have not voted yet (sorted by stake from larger to smaller):"
for key in "${sortedNotVotedKeys[@]}"; do
    echo "DRep: $key - Stake: ${notVotedDReps[$key]}"
done