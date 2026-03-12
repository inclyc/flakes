import json
import os
import urllib.error
import urllib.request

import yaml


def update_mihomo_config(sub_url, api, secret, base_cfg_path):
    if base_cfg_path is None:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        base_cfg_path = os.path.join(current_dir, "base.yaml")

    # 下载并解析订阅内容
    with urllib.request.urlopen(
        urllib.request.Request(
            sub_url,
            headers={
                "User-Agent": "clash-verge/v1.3.8",
                "Accept": "*/*",
            },
        )
    ) as resp:
        sub_data = yaml.safe_load(resp.read().decode("utf-8", errors="ignore"))

    # 读取并合并配置：sub_data 提供基础，base_cfg 进行覆盖更新
    with open(base_cfg_path, "r", encoding="utf-8") as f:
        full_config = {**sub_data, **yaml.safe_load(f)}

    # 发送 PUT 请求重载内核
    try:
        # 更新时不要使用 https_proxy/http_proxy 等环境变量
        proxy_handler = urllib.request.ProxyHandler({})
        opener = urllib.request.build_opener(proxy_handler)

        with opener.open(
            urllib.request.Request(
                url=f"{api}/configs?force=true",
                data=json.dumps({"path": "", "payload": yaml.dump(full_config)}).encode(
                    "utf-8"
                ),
                headers={
                    "Authorization": f"Bearer {secret}",
                    "Content-Type": "application/json",
                },
                method="PUT",
            )
        ) as r:
            print(f"Mihomo API Response: {r.status} {r.reason}")
    except urllib.error.HTTPError as e:
        print(f"Mihomo API Error (Status {e.code}): {e.read().decode('utf-8')}")
        raise


def main():
    update_mihomo_config(
        sub_url=os.environ["SUB_URL"],
        api=os.environ["MIHOMO_API"],
        secret=os.environ["MIHOMO_SECRET"],
        base_cfg_path=os.getenv("BASE_CONFIG_PATH"),
    )


if __name__ == "__main__":
    main()
