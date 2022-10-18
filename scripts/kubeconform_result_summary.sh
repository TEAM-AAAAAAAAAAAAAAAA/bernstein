#!/usr/bin/bash

echo "| ressource | value |"
for i in ${{fromJson(steps.set_var.outputs.packageJson).resources}}
do
    echo "resource"
done
echo "| summary | value |"
echo "|---------|-------|"
echo "| valid   | ${{fromJson(steps.set_var.outputs.packageJson).summary.valid}}     |"
echo "| invalid | ${{fromJson(steps.set_var.outputs.packageJson).summary.invalid}}     |"
echo "| errors  | ${{fromJson(steps.set_var.outputs.packageJson).summary.errors}}     |"
echo "| skipped | ${{fromJson(steps.set_var.outputs.packageJson).summary.skipped}}     |"