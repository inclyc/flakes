use git2::{BranchType, Repository};
use std::io::{self, Write};

fn main() -> Result<(), git2::Error> {
    let repo = Repository::open_from_env()?;

    let branches = repo.branches(Some(BranchType::Local))?;

    let mut no_remote_branches = Vec::new();

    for branch in branches.flatten() {
        let (branch, _branch_type) = branch;
        let name = branch.name()?.expect("Branch name should be valid UTF-8");

        // Skip detached HEAD or invalid names
        if name.is_empty() {
            continue;
        }

        // Check if there's a remote tracking branch
        if let Ok(_upstream) = branch.upstream() {
            // Upstream exists, skip
            continue;
        } else {
            println!("⚠️ No remote tracking branch found for '{}'", name);
            no_remote_branches.push(name.to_string());
        }
    }

    if no_remote_branches.is_empty() {
        println!("🎉 All local branches have corresponding remote branches.");
        return Ok(());
    }

    // Show list and ask confirmation
    println!("\n🗑 The following branches have no remote tracking branch:");
    for name in &no_remote_branches {
        println!(" - {}", name);
    }

    print!("\nAre you sure you want to delete these branches? (y/N): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    if input.trim().eq_ignore_ascii_case("y") {
        for name in &no_remote_branches {
            match repo.find_branch(name, BranchType::Local) {
                Ok(mut branch) => {
                    if let Err(e) = branch.delete() {
                        eprintln!("❌ Failed to delete branch '{}': {}", name, e);
                    } else {
                        println!("✅ Deleted branch '{}'", name);
                    }
                }
                Err(e) => {
                    eprintln!("❌ Could not find branch '{}': {}", name, e);
                }
            }
        }
    } else {
        println!("🛑 Operation canceled.");
    }

    Ok(())
}
