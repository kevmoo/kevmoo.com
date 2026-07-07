#!/usr/bin/env python3
"""
fetch_landed_changes.py

A utility script to query merged GitHub Pull Requests and direct commits using the GitHub CLI (`gh`),
filter by author and organization, and generate a Markdown research dataset.
"""

import argparse
import json
import os
import subprocess
from collections import defaultdict
from datetime import datetime, timedelta

def run_command(cmd):
    try:
        result = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {' '.join(cmd)}\n{e.stderr}")
        return ""

def main():
    parser = argparse.ArgumentParser(description="Fetch landed PRs and commits from GitHub CLI.")
    parser.add_argument("--days", type=int, default=60, help="Number of days back to search (default: 60)")
    parser.add_argument("--author", type=str, default="@me", help="PR author (default: @me)")
    parser.add_argument("--email", type=str, default="kevmoo@google.com", help="Author email for direct SDK commits")
    parser.add_argument("--exclude-org", type=str, default="kevmoo", help="Organization prefix to exclude")
    parser.add_argument("--output", type=str, default="landed_changes_report.md", help="Output file path")
    
    args = parser.parse_args()
    
    since_date = (datetime.now() - timedelta(days=args.days)).strftime("%Y-%m-%d")
    print(f"Searching for changes since {since_date}...")
    
    # 1. Fetch PRs
    pr_cmd = [
        "gh", "search", "prs",
        f"--author={args.author}",
        "--merged",
        f"--merged-at=>={since_date}",
        "--limit", "500",
        "--json", "repository,number,title,closedAt,url,body"
    ]
    pr_out = run_command(pr_cmd)
    prs = json.loads(pr_out) if pr_out else []
    
    # 2. Fetch SDK Commits
    commit_cmd = [
        "gh", "search", "commits",
        "--repo=dart-lang/sdk",
        f"--author-date=>={since_date}",
        f"--author-email={args.email}",
        "--limit", "200",
        "--json", "sha,commit,url,repository"
    ]
    commit_out = run_command(commit_cmd)
    commits = json.loads(commit_out) if commit_out else []
    
    # 3. Filter and Group
    repos = defaultdict(list)
    
    for pr in prs:
        repo_name = pr['repository']['nameWithOwner']
        if args.exclude_org and repo_name.startswith(f"{args.exclude_org}/"):
            continue
        repos[repo_name].append({
            'kind': 'PR',
            'id': f"#{pr['number']}",
            'title': pr['title'],
            'date': pr['closedAt'][:10],
            'url': pr['url'],
            'body': pr.get('body', '') or ''
        })
        
    for c in commits:
        repo_name = c['repository']['fullName']
        if args.exclude_org and repo_name.startswith(f"{args.exclude_org}/"):
            continue
        msg_lines = c['commit']['message'].strip().split('
')
        title = msg_lines[0]
        body = '
'.join(msg_lines[1:]).strip()
        date_str = c['commit']['author']['date'][:10]
        repos[repo_name].append({
            'kind': 'Commit',
            'id': c['sha'][:8],
            'title': title,
            'date': date_str,
            'url': c['url'],
            'body': body
        })
        
    total_changes = sum(len(items) for items in repos.values())
    sorted_repos = sorted(repos.items(), key=lambda x: len(x[1]), reverse=True)
    
    print(f"Found {total_changes} changes across {len(repos)} repositories.")
    
    # 4. Generate Markdown
    lines = [
        "# 🛠️ Landed Changes Research Report",
        "",
        f"> **Timeframe**: Since {since_date} ({args.days} days)  ",
        f"> **Total Landed Changes**: **{total_changes}**  ",
        f"> **Total Repositories Touched**: **{len(repos)}**  ",
        ""
    ]
    if args.exclude_org:
        lines.append(f"> **Excluded Org**: `{args.exclude_org}/*`  
")
        
    lines.extend([
        "---",
        "",
        "## 📊 Repository Breakdown",
        "",
        "| Repository | Landed Changes | Kind |",
        "| :--- | :---: | :--- |"
    ])
    
    for repo_name, items in sorted_repos:
        kinds = set(i['kind'] for i in items)
        kind_str = 'PRs & Commits' if len(kinds) > 1 else list(kinds)[0] + 's'
        lines.append(f"| `{repo_name}` | {len(items)} | {kind_str} |")
        
    lines.extend([
        "",
        "---",
        "",
        "## 📂 Complete Inventory by Repository",
        ""
    ])
    
    for repo_name, items in sorted_repos:
        lines.append(f"### {repo_name} ({len(items)} changes)
")
        for item in items:
            title_esc = item['title'].replace('[', '\[').replace(']', '\]')
            body_snippet = item['body'].replace('', '').strip()
            if len(body_snippet) > 250:
                body_snippet = body_snippet[:250].replace('
', ' ') + "..."
            else:
                body_snippet = body_snippet.replace('
', ' ')
                
            lines.append(f"- [{item['id']}]({item['url']}) `{item['date']}` **{title_esc}**")
            if body_snippet:
                lines.append(f"  > {body_snippet}")
        lines.append("")
        
    with open(args.output, "w") as f:
        f.write('
'.join(lines))
        
    print(f"Report written to: {args.output}")

if __name__ == "__main__":
    main()
