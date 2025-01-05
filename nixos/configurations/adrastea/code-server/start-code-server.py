import subprocess
import os
import os.path

subprocess.run(
    [
        f"{os.environ["WebHost"]}/bin/code-server",
        "--host",
        "127.0.0.1",
        "--port",
        os.environ["Port"],
        "--connection-token-file",
        os.environ["ConnectionTokenFile"],
        "--accept-server-license-terms",
    ]
)
