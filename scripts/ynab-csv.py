# Convert CSVs into YNAB format for import
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from datetime import datetime
from pathlib import Path

import csv, sys

parser = ArgumentParser(description="A script to convert bank CSVs to YNAB format. Outputs as <file>_mapped.csv", \
                            formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("file", help="CSV file to convert");
parser.add_argument("-b", "--bank", help="The bank/format to convert from.", default="e", choices=['e', 'ecard'])
args = parser.parse_args()

match args.bank:
    case 'e': # Columns are Date,Description,Transfer,Balance
        with open(args.file, mode='r', newline='', encoding='utf-8-sig') as raw_csvfile:
            csvfile = csv.DictReader(raw_csvfile)

            with open(Path(args.file).with_suffix('').__str__() +"_mapped.csv", \
                        newline='', mode="w") as new_rawfile:
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
    case 'ecard': # Columns are Date,Description,Amount
        with open(args.file, mode='r', newline='', encoding='utf-8-sig') as raw_csvfile:
            csvfile = csv.DictReader(raw_csvfile)

            with open(Path(args.file).with_suffix('').__str__() +"_mapped.csv", \
                        newline='', mode="w") as new_rawfile:
                newfile = csv.DictWriter(new_rawfile, fieldnames=["Date", "Payee", "Memo", "Amount"])
                newfile.writeheader()

                for row in csvfile:
                    # Convert date from DD MMM YYYY to ISO 8601
                    new_date = "{0:%Y}-{0:%m}-{0:%d}".format(datetime.strptime(row["Date"], "%d %b %Y"))

                    # Try to guess payee
                    payee = row["Description"].split(',')[0]

                    # Format amount to numeric
                    amount = "{:.2f}".format(float(row["Amount"].replace('$','')))

                    newfile.writerow({"Date": new_date, "Payee": payee, "Memo": row["Description"], "Amount": amount})
    case _:
        print("Other banks are not supported, sorry.",file=sys.stderr)