import re
import subprocess

remotes = subprocess.getoutput("git remote -v").splitlines()
upstream = [remote for remote in remotes if "upstream" in remote]
if len(upstream) == 2:
    upstream = upstream[0]
else:
    raise NameError("Remote `upstream` not found")

branch: str
if any(repo in upstream for repo in ["wildfly-core", "wildfly/wildfly", "elytron-examples", "quickstart",
        "wildfly.org", "wildfly-proposals"]):
    branch = "main"
elif "wildfly-elytron" in upstream:
    branch = "2.x"
elif "elytron-web-jetty" in upstream:
    branch = "master"
else:
    raise NameError("Remote `upstream` is unrecognized")

commit_msg: str = subprocess.getoutput(f"git log --oneline {branch}..HEAD").splitlines()[-1]
commit_msg = commit_msg[commit_msg.find('['):]
jira_match = re.search(r"\[(\w+-\d+)\]",commit_msg)
if jira_match is not None:
    jira: str = jira_match.group(1)
else:
    raise LookupError("JIRA issue code is not in commit message")

pr_command = ['gh', 'pr', 'create', '-B', branch, '-b', f'https://issues.redhat.com/browse/{jira}',
        "-t", f"{commit_msg}"]

if input(
f"""PR details
    Title:         {pr_command[8]}
    Body:          {pr_command[6]}
    Base branch:   {pr_command[4]}
    
Confirm? [y/N] """).lower()[0] == 'y': 
    subprocess.run(pr_command)
else:
    print("PR not created.\n")