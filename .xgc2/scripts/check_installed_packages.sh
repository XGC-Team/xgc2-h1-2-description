#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/jazzy/setup.bash
set -u

dpkg -s ros-jazzy-xgc2-h1-2-description >/dev/null
package_prefix="$(ros2 pkg prefix h1_2_description)"
test "${package_prefix}" = /opt/ros/jazzy
package_path="${package_prefix}/share/h1_2_description"
test -f "${package_path}/meshes/pelvis.STL"
test -f "${package_path}/meshes/left_hip_yaw_link.STL"
test -f "${package_path}/urdf/h1_2_visual.urdf"
test -f "${package_path}/ASSET_SHA256SUMS"
test -f /opt/ros/jazzy/share/ament_index/resource_index/packages/h1_2_description

(
  cd "${package_path}"
  sha256sum --check ASSET_SHA256SUMS
)

python3 - "${package_path}/urdf/h1_2_visual.urdf" <<'PY'
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
assert root.attrib["name"] == "h1_2"
assert len(root.findall("link")) == 56
assert len(root.findall("joint")) == 55
for tag in ("collision", "inertial", "transmission", "gazebo", "plugin"):
    assert not root.findall(f".//{tag}"), tag
PY

echo "Installed package check passed."
