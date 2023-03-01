# Convert CSVs into YNAB format for import
from argparse import ArgumentParser
from datetime import datetime

import csv, sys

parser = ArgumentParser(description="A script to convert bank CSVs to YNAB format. Outputs as <file>_mapped.csv")
parser.add_argument("file", help="CSV file to convert");
parser.add_argument("-b", "--bank", help="The bank to convert from. Defaults to 'e'.", default="e")
args = parser.parse_args()

if args.bank == 'e': # Columns are Date,Description,Transfer,Balance
    with open(args.file, newline='') as raw_csvfile:
        csvfile = csv.DictReader(raw_csvfile)

        with open(args.file[:-4]+"_mapped.csv", newline='', mode="w") as new_rawfile:
            newfile = csv.DictWriter(new_rawfile, fieldnames=["Date", "Payee", "Memo", "Amount"])
            newfile.writeheader()

            for row in csvfile:
                # Convert date from DD MMM YYYY to ISO 8601
                new_date = "{0:%Y}-{0:%m}-{0:%d}".format(datetime.strptime(row["Date"], "%d %b %Y"))

                # Try to guess payee
                desc = row["Description"]
                if "to " in desc:
                    payee = desc[desc.find("to ")+3:].lstrip()
                elif "from " in desc:
                    payee = desc[desc.find("from ")+5:].lstrip()
                else:
                    payee = desc

                # Format amount to numeric
                amount = "{:.2f}".format(float(row["Transfer"].replace('$','')))

                newfile.writerow({"Date": new_date, "Payee": payee, "Memo": row["Description"], "Amount": amount})

else:
    print("Other banks are not supported, sorry.",file=sys.stderr)