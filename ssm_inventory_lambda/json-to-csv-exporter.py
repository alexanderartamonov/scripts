import json
import glob
from datetime import datetime
import csv

# Place your JSON data in a directory named 'data/'
src = "inventory/"

date = datetime.now()
data = []

# Change the glob if you want to only look through files with specific names
files = glob.glob('inventory/i-e5d83a64.json', recursive=True)

# Loop through files

for single_file in files:
  with open(single_file, 'r') as f:

    # Use 'try-except' to skip files that may be missing data
    try:
      json_file = json.load(f)
      data.append([
        json_file['Status'],
        json_file['ServiceType'],
        json_file['ServicesDependedOn'],
        json_file['DisplayName'],
        json_file['Name'],
        json_file['StartType']
      ])
    except KeyError:
      print(f'Skipping {single_file}')

# Sort the data
data.sort()

# Add headers
data.insert(0, ['Name', 'Status','ServiceType','ServicesDependedOn','DisplayName','StartType'])

# Export to CSV.
# Add the date to the file name to avoid overwriting it each time.
csv_filename = f'{str(date)}.csv'
with open(csv_filename, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(data)

print("Updated CSV")