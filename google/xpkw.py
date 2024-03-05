import argparse
import subprocess
from typing import Optional
# TODO: unify this with tpugpu.py?

PROJECT: str = "tpu-prod-env-multipod"

_CHIP_TO_ZONE: dict[str, str] = {
    "5e": "us-west4-a",
    "4": "us-central2-b"
}

_CHIP_TO_CLUSTER: dict[str, str] = {
        "4": "v4-bodaborg",
        "5e": "v5e-bodaborg"
}


class XPKConfig:
    def __init__(self, chip: str, count: int, slices: Optional[int] = NOne) -> None:
        self._chip: str = chip
        self._count: int = count
        self._cluster: str = _CHIP_TO_CLUSTER[chip]
        self._zone: str = _CHIP_TO_ZONE[chip]
        self._project: str = PROJECT
        self._slices: int = slices or 1

    @property
    def cluster(self) -> list[str]:
        return ["--cluster", self._cluster]

    @property
    def tpu_type(self) -> list[str]:
        return ["--tpu-type", self._tpu_type_arg]

    @property
    def num_slices(self) -> list[str]:
        return ["--num-slices", str(self._slices)]

    @property
    def zone(self) -> list[str]:
        return ["--zone", self._zone]

    @property
    def project(self) -> list[str]:
        return ["--project", self._project]

    @property
    def _tpu_type_arg(self) -> str:
        return f"v{self._chip}-{self._count}"
        

def run_subprocess(command: list[str]) -> str:
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, text=True)
        print(output)
        return output.strip()
    except subprocess.CalledProcessError as e:
        print(e.output)
        raise

def run_cmd_via_xpk(config: XPKConfig, cmd: str, docker_image: str) -> None:
    run_subprocess([
        "xpk",
        "workload",
        "create",
        *config.cluster,
        "--base-docker-image",
        docker_image,
        "--workload",
        "carterblum-first-job", # todo: find better naming scheme
        *config.tpu_type,
        *config.num_slices,
        *config.zone,
        *config.project,
        "--command",
        cmd
    ])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("chip", type=str)
    parser.add_argument("count", type=int)
    parser.add_argument("command", type=str)
    parser.add_argument("--slices", type=int, default=None)
    args = parser.parse_args()


    cfg = XPKConfig(args.chip, args.count, args.slices)
    run_cmd_via_xpk(cfg, args.command, docker_image="maxtext_base_image") # todo: find a more suitable replacement
