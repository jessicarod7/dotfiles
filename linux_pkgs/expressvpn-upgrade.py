# ExpressVPN Fedora amd64 Update Script v1.0
# (c) 2022, rn10950
# Modified-By: Cameron Rodriguez (GitHub: @cam-rod)
# Original source: https://pastebin.com/6GqM8W8E via https://reddit.com/comments/us7j1y/_/ion19vf
#
# This script is provided as a convenience, to address the lack
# of an official update script. I am not affiliated with
# ExpressVPN in any way.
#
# It may be freely distributed and improved, use at your own risk.
# Do not run this script if you do not understand what it does.
# 
# dependencies:
# - BeautifulSoup (pip3 install beautifulsoup4)
# - packaging (included with setuptools, pip3 install packaging)


from argparse import ArgumentParser, Namespace
from bs4 import BeautifulSoup
from packaging.version import Version
from urllib.request import urlopen
import subprocess
import sys

def checkVersion(installing: bool) -> Version:
	try:
		versionS = subprocess.check_output(['expressvpn', '--version'])
		versionL = versionS.split()
		return Version(versionL[2].decode('utf-8'))
	except:
		if installing:
			return Version("0")
		else:
			print("Invalid option: ExpressVPN is not installed. Use the --install option.\n")
			quit()

def downloadAndVerifyRPM(args: Namespace, newVersion: Version, rpmURL: str, rpmSigURL: str) -> str:
	rpmFile = "/tmp/expressvpn-" + str(newVersion) + ".rpm"
	rpmStream = urlopen(rpmURL)
	with open(rpmFile, 'b+w') as rpmFileStream:
		rpmFileStream.write(rpmStream.read())

	rpmSigFile = rpmFile + ".asc"
	sigStream = urlopen(rpmSigURL)
	with open(rpmSigFile, 'b+w') as sigFileStream:
		sigFileStream.write(sigStream.read())

	# Verify
	if args.no_gpg_check:
		print("Package signature check skipped.")
	else:
		if (subprocess.call(["gpg", "--verify", rpmSigFile, rpmFile], stdout=subprocess.DEVNULL) != 0):
			print("ERROR: Package signature could not be verified. Please check that the ExpressVPN PGP key is added to root.", file=sys.stderr)
			print("Alternatively, run with '--no-gpg-check' to suppress this check. Cancelling upgrade.", file=sys.stderr)
			print(rpmSigFile)
			sys.exit(2)
		else:
			print("Package signature verified.")

	return rpmFile

def upgrade(args: Namespace, newVersion: Version, rpmURL: str, rpmSigURL: str) -> None:
	currVersion = checkVersion(args.install)

	if currVersion < newVersion:
		while True:
			print("There is an upgrade available for ExpressVPN (" + str(currVersion) + " -> " + str(newVersion) + ").\n")
			p = input("Install? [y/N] ")
			if p.lower() == 'y':
				print("\nUpgrading ExpressVPN...")
				rpmFile = downloadAndVerifyRPM(args, newVersion, rpmURL, rpmSigURL)

				subprocess.call(["sudo", "dnf", "install", rpmFile])
				sys.exit()
			else:
				print("\nUpgrade cancelled.\n", file=sys.stderr)
				sys.exit(1)

	elif currVersion == newVersion:
		print("\nExpressVPN is fully upgraded to version " + str(currVersion) + ".\n")
	else:
		print("ERROR: Latest version (" + str(newVersion) + ") is lower than installed version (" + str(currVersion) + "). Cancelling upgrade.\n", file=sys.stderr)
		sys.exit(3)

def install(args: Namespace, newVersion: Version, rpmURL: str, rpmSigURL: str) -> None:
	if checkVersion(args.install) != Version("0"):
		print("Invalid option: ExpressVPN is already installed. Do not use the --install option.\n")
		sys.exit(3)

	p = input(f"Confirm installation of ExpressVPN {str(newVersion)} [y/N]: ")
	if p.lower() == 'y':
		print("\nInstalling ExpressVPN...")
		rpmFile = downloadAndVerifyRPM(args, newVersion, rpmURL, rpmSigURL)
		
		subprocess.call(["sudo", "dnf", "install", rpmFile])
		sys.exit()
	else:
		print("\nInstallation cancelled.\n", file=sys.stderr)
		sys.exit(1)

if __name__ == "__main__":
	parser = ArgumentParser(prog="ExpressVPN Upgrader and Installer", description="A small script to upgrade (or install) Fedora x86_64 versions of ExpressVPN")
	parser.add_argument("-i", "--install", help="Install the latest version of ExpressVPN on a device that doesn't already have it",
						action="store_true")
	parser.add_argument("-nogpg", "--no-gpg-check", help="Do not check if the signature of the downloaded package matches the ExpressVPN " + \
		  "release key (see https://www.expressvpn.com/support/vpn-setup/pgp-for-linux/)", action='store_true')
	args: Namespace = parser.parse_args()


	url: str = "https://www.expressvpn.com/latest#linux?utm_source=linux_app"
	page = urlopen(url)
	soup = BeautifulSoup(page, "html.parser")
	linkTag = soup.find_all("option", text = "Fedora 64-bit")

	tag = linkTag[0]
	rpmURL = tag['value']
	newVersion = Version(tag['data-version'])
	rpmSigURL = rpmURL + ".asc"

	install(args, newVersion, rpmURL, rpmSigURL) if args.install else upgrade(args, newVersion, rpmURL, rpmSigURL)