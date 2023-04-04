from argparse import ArgumentParser, Namespace
from typing import Final
import subprocess as sp
import sys

RED: Final[str] ='\033[31m'
GREEN: Final[str] ='\033[32m'
BLUE: Final[str] ='\033[36m'
BOLD: Final[str] ='\033[1m'
RESET: Final[str] ='\033[0m'

def error_out(output: sp.CompletedProcess):
    print(output.stderr, file=sys.stderr)
    sys.exit(output.returncode)

def run_cmd(cmd: list[str]) -> sp.CompletedProcess:
    output: sp.CompletedProcess = sp.run(cmd, capture_output=True, encoding='utf-8')

    if (output.returncode == 2):
        error_out(output)
    return output

def diff_files(args: Namespace):
    cmd_result = run_cmd(["diff", "-u", args.file1, args.file2])
    output: list[str] = cmd_result.stdout.splitlines()

    if len(output) > 0:
        print(BOLD + output[0] + '\n' + output[1] + RESET)
        del(output[0:2])
        for line in output:
            if (line[0] == '-'):
                print(RED + line + RESET)
            elif (line[0] == '+'):
                print(GREEN + line + RESET)
            elif (line[0] == '@'):
                print(BLUE + line + RESET)
            else:
                print(line)

    sys.exit(cmd_result.returncode)

if __name__ == "__main__":
    parser = ArgumentParser(prog='colodiff', description="diff but with color for containers that don't have modern diffutils")
    parser.add_argument("file1")
    parser.add_argument("file2")
    args: Namespace = parser.parse_args()

    diff_files(args)
