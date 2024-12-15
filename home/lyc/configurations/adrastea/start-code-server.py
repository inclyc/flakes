import subprocess
import os

subprocess.run(
    [
        f"{os.environ["CODIUM_REH"]}/bin/codium-server",
        "--host",
        "::1",
        "--port",
        os.environ["PORT"],
        "--without-connection-token",
    ]
)
