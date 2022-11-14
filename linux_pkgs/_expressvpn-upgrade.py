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


from urllib.request import urlopen
from bs4 import BeautifulSoup
from packaging.version import Version
import subprocess
import sys

def help() -> None:
	print("ExpressVPN Upgrader and Installer\n")
	print("==================================\n")
	print("This script is best used with the script `expressvpn-upgrade` as a caller.\n")
	print("Usage: expressvpn-upgrade [--install] [--no-gpg-check]\n")
	print("Options:\n")
	print("\t--install: Install ExpressVPN instead of upgrading\n")
	print("\t--no-gpg-check: Do not check if the signature of the downloaded package matches the ExpressVPN\n" + \
		  "\t                release key (see https://www.expressvpn.com/support/vpn-setup/pgp-for-linux/)\n")

def checkVersion(install_option: bool=False) -> Version:
	try:
		versionS = subprocess.check_output(['expressvpn', '--version'])
		versionL = versionS.split()
		return Version(versionL[2].decode('utf-8'))
	except:
		if install_option:
			return Version("0")
		
		print("Invalid option: ExpressVPN is not installed. Use the --install option.\n")
		quit()

def downloadAndVerifyRPM(newVersion: Version, rpmURL: str, rpmSigURL: str) -> str:
	rpmFile = "/tmp/expressvpn-" + str(newVersion) + ".rpm"
	rpmStream = urlopen(rpmURL)
	with open(rpmFile, 'b+w') as rpmFileStream:
		rpmFileStream.write(rpmStream.read())

	rpmSigFile = rpmFile + ".asc"
	sigStream = urlopen(rpmSigURL)
	with open(rpmSigFile, 'b+w') as sigFileStream:
		sigFileStream.write(sigStream.read())

	# Verify
	if '--no-gpg-check' not in sys.argv:
		if (subprocess.call(["gpg", "--verify", rpmSigFile, rpmFile], stdout=subprocess.DEVNULL) != 0):
			print("ERROR: Package signature could not be verified. Please check that the ExpressVPN PGP key is added to root.\n", file=sys.stderr)
			print("Alternatively, run with '--no-gpg-check' to suppress this check. Cancelling upgrade.\n", file=sys.stderr)
			print(rpmSigFile)
			sys.exit(2)
		else:
			print("Package signature verified.\n")

	return rpmFile

def upgrade(newVersion: Version, rpmURL: str, rpmSigURL: str) -> None:
	currVersion = checkVersion()

	if currVersion < newVersion:
		while True:
			print("There is an upgrade available for ExpressVPN (" + str(currVersion) + " -> " + str(newVersion) + ").\n")
			p = input("Install? [y/N] ")
			if p.lower() == 'y':
				print("\nUpgrading ExpressVPN...\n")
				rpmFile = downloadAndVerifyRPM(newVersion, rpmURL, rpmSigURL)

				subprocess.call("sudo dnf install " + rpmFile)
				sys.exit()
			else:
				print("\nUpgrade cancelled.\n", file=sys.stderr)
				sys.exit(1)

	elif currVersion == newVersion:
		print("\nExpressVPN is fully upgraded to version " + str(currVersion) + ".\n")
	else:
		print("ERROR: Latest version (" + str(newVersion) + ") is lower than installed version (" + str(currVersion) + "). Cancelling upgrade.\n", file=sys.stderr)
		sys.exit(3)

def install(newVersion: Version, rpmURL: str, rpmSigURL: str) -> None:
	if checkVersion(True) is not Version("0"):
		print("Invalid option: ExpressVPN is already installed. Do not use the --install option.\n")
		sys.exit(3)

	p = input(f"Confirm installation of ExpressVPN {str(newVersion)} [y/N]: ")
	if p.lower() == 'y':
		print("\nInstalling ExpressVPN...")
		rpmFile = downloadAndVerifyRPM(newVersion, rpmURL, rpmSigURL)
		
		subprocess.call("sudo dnf install " + rpmFile)
		sys.exit()
	else:
		print("\nInstallation cancelled.\n", file=sys.stderr)
		sys.exit(1)

if __name__ == "__main__":
	if '--help' in sys.argv:
		help()

	url = "https://www.expressvpn.com/latest#linux?utm_source=linux_app"
	page = urlopen(url)
	soup = BeautifulSoup(page, "html.parser")
	linkTag = soup.find_all("option", text = "Fedora 64-bit")

	tag = linkTag[0]
	rpmURL = tag['value']
	newVersion = Version(tag['data-version'])
	rpmSigURL = rpmURL + ".asc"

	install(newVersion, rpmURL, rpmSigURL) if '--install' in sys.argv else upgrade(newVersion, rpmURL, rpmSigURL)