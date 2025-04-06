import os.path
import re
import subprocess
import urllib.request
from typing import Tuple


def fetch_latest_vscode_info() -> Tuple[str, str, str]:
    """从Nixpkgs仓库获取最新的VSCode信息"""
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/vscode/vscode.nix"
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read().decode('utf-8')
    except Exception as e:
        raise ValueError(f"无法获取远程文件: {e}")

    # 提取version
    version_match = re.search(r'version\s*=\s*"([^"]+)"', content)
    if not version_match:
        raise ValueError("无法提取version")
    version = version_match.group(1)

    # 提取rev
    rev_match = re.search(r'rev\s*=\s*"([^"]+)"', content)
    if not rev_match:
        raise ValueError("无法提取rev")
    rev = rev_match.group(1)

    # 提取完整的sha256块，包括前面的sha256 = 部分
    sha256_match = re.search(r'(sha256\s*=\s*{\s*[\s\S]*?\}\s*\.\$\{system\} or throwSystem;)', content)
    if not sha256_match:
        raise ValueError("无法提取sha256块")
    sha256_block = sha256_match.group(1)

    return version, rev, sha256_block

def format_with_nixfmt(file_path: str) -> bool:
    """使用nixfmt格式化文件"""
    try:
        subprocess.run(["nixfmt", file_path], check=True)
        return True
    except subprocess.CalledProcessError:
        print("警告: nixfmt格式化失败，文件内容仍然有效但格式可能不完美")
        return False
    except FileNotFoundError:
        print("提示: 未找到nixfmt，跳过格式化步骤")
        return False

def update_nix_file(file_path: str, version: str, rev: str, sha256_block: str) -> None:
    """更新Nix文件，保持原有格式"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
    except IOError as e:
        raise ValueError(f"无法读取文件 {file_path}: {e}")

    # 更新version
    content = re.sub(r'version\s*=\s*"[^"]+"', f'version = "{version}"', content)

    # 更新rev
    content = re.sub(r'rev\s*=\s*"[^"]+"', f'rev = "{rev}"', content)

    # 更新sha256块 - 精确替换整个sha256块
    # 首先找到原始sha256块的范围
    sha256_pattern = re.compile(
        r'sha256\s*=\s*{\s*[\s\S]*?\}\s*\.\$\{system\} or throwSystem;',
        re.DOTALL
    )
    content = sha256_pattern.sub(sha256_block, content)

    try:
        with open(file_path, 'w') as f:
            f.write(content)

        # 尝试格式化文件
        format_with_nixfmt(file_path)
    except IOError as e:
        raise ValueError(f"无法写入文件 {file_path}: {e}")

def main():
    print("正在获取最新的VSCode信息...")
    try:
        # 获取最新信息
        version, rev, sha256_block = fetch_latest_vscode_info()
        print(f"最新版本: {version}")
        print(f"修订号: {rev}")
        print("完整的SHA256块:")
        print(sha256_block)

        # 更新文件
        file_path = os.path.join(os.path.dirname(__file__), "default.nix")
        update_nix_file(file_path, version, rev, sha256_block)
        print(f"\n已成功更新文件: {file_path}")

    except Exception as e:
        print(f"错误: {e}")
        print("更新失败，请检查错误信息")

if __name__ == "__main__":
    main()
