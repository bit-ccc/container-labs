#! /bin/sh

useradd demo-user

mkdir demo-dir

echo This is docker demo 123 > /demo-dir/demo-file
chown -R demo-user:demo-user /demo-dir